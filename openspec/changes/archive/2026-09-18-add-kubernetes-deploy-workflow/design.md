## Context

O repositório `ci-templates` centraliza workflows reutilizáveis. Hoje o `publish-image.yml` publica a imagem com tag imutável `<registry>/<namespace>/<image>:<sha>`. Não existe caminho para levar essa imagem ao cluster Kubernetes. O consumidor típico é um repo de aplicação que chama os templates via `workflow_call` e mantém seus manifests em um repo de infraestrutura separado, com cluster genérico (kubeconfig) e Helm como ferramenta de deploy.

## Goals / Non-Goals

**Goals:**
- Template reutilizável `deploy-kubernetes.yml` que faz deploy via Helm de uma imagem já publicada.
- Autenticação no cluster por kubeconfig (secret único base64), sem dependência de provedor de nuvem.
- Chart obtido por checkout do repo de infraestrutura (PAT com leitura).
- Suporte a registry privado via `imagePullSecret` criado/atualizado de forma idempotente.
- Resolução da referência da imagem compartilhada com o publish (fonte única de verdade).
- Falha cedo se o rollout não completar.

**Non-Goals:**
- GitOps (ArgoCD/Flux) — deploy direto via CI, conforme decisão do usuário.
- Suporte a provedores específicos (AKS/EKS/GKE) com actions próprias — o kubeconfig genérico cobre todos.
- Publicação de charts em Helm repo (OCI/ChartMuseum) — o chart é consumido direto do git.
- Gerenciamento de secrets da aplicação — o chart deve referenciar secrets já existentes no cluster.

## Decisions

### 1. Autenticação no cluster: kubeconfig único (base64)

O secret `KUBECONFIG` contém o kubeconfig completo codificado em base64; o workflow grava em `~/.kube/config` com permissão `600`.

- **Alternativas consideradas**: secrets separados (`KUBE_SERVER` + `KUBE_CA` + `KUBE_TOKEN`) e actions por provedor (AKS/EKS/GKE).
- **Por quê**: cluster genérico, um único secret, funciona em qualquer provedor. Secrets separados exigem montar o kubeconfig no workflow (mais lógica); actions por provedor acoplam o template a um cloud específico.

### 2. Acesso ao chart: checkout do repo de infra

O workflow faz checkout do repo de infraestrutura (variável `INFRA_REPO`) com `INFRA_TOKEN` (PAT fine-grained com leitura) e usa `chart_path` para localizar o chart.

- **Alternativas consideradas**: chart publicado em Helm repo (OCI/ChartMuseum).
- **Por quê**: mais simples, sem infraestrutura extra de publicação; o chart evolui junto com o repo de infra. Trade-off: o deploy depende de acesso de leitura ao repo de infra a cada run.

### 3. Referência da imagem: recalculada via script compartilhado

A lógica de resolução (`<registry>/<namespace>/<image>:<sha>`) é extraída para `scripts/resolve-image-ref.sh`, chamado tanto pelo `publish-image.yml` quanto pelo `deploy-kubernetes.yml`. O script emite `repository` (sem tag) e `tag` separados, para o Helm.

- **Alternativas consideradas**: `publish-image.yml` expor `outputs.image_ref` e o deploy consumir via `needs`.
- **Por quê**: o usuário optou por recalcular; o script compartilhado elimina a duplicação sem acoplar os dois workflows por outputs. O deploy ainda usa `needs: publish` no repo consumidor apenas para ordenação (a imagem precisa existir antes).

### 4. Registry privado: `imagePullSecret` idempotente

Antes do `helm upgrade`, o workflow cria/atualiza o secret de tipo `kubernetes.io/dockerconfigjson` no namespace:

```bash
kubectl create secret docker-registry "$IMAGE_PULL_SECRET_NAME" \
  --docker-server="$REGISTRY" \
  --docker-username="$REGISTRY_USERNAME" \
  --docker-password="$REGISTRY_PASSWORD" \
  --namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -
```

O nome do secret é configurável via `IMAGE_PULL_SECRET_NAME`; o chart deve referenciá-lo em `imagePullSecrets`.

### 5. Aplicação: `helm upgrade --install` com `--set`

```bash
helm upgrade --install "$RELEASE_NAME" "./infra/$CHART_PATH" \
  --namespace "$NAMESPACE" \
  --set "image.repository=$REPOSITORY" \
  --set "image.tag=$TAG" \
  --wait --timeout 5m
```

O chart precisa expor `image.repository` e `image.tag` no `values.yaml`. `--wait` garante que o release esteja saudável antes de prosseguir.

### 6. Verificação: `kubectl rollout status`

Após o upgrade, verifica-se o rollout do deployment para falhar cedo com erro claro se a imagem não subir (ex.: `ImagePullBackOff`).

### 7. Ambiente: `environment: production`

O job usa `environment: production` (mesmo padrão do publish), permitindo gate de aprovação e isolamento de secrets por ambiente.

## Risks / Trade-offs

- **Credencial do cluster exposta no GitHub** → Usar ServiceAccount com permissão mínima (somente o namespace de deploy), nunca admin do cluster; o secret `KUBECONFIG` deve ter escopo restrito.
- **`ImagePullBackOff` por registry privado** → O `imagePullSecret` é criado antes do upgrade e o `rollout status` falha cedo; documentar que o chart deve referenciar o secret.
- **Lógica de resolução duplicada entre publish e deploy** → Mitigada pelo script compartilhado `resolve-image-ref.sh`; manter o script como única fonte de verdade.
- **PAT do repo de infra com escopo amplo** → Usar PAT fine-grained com leitura apenas no repo de infra necessário.
- **`--wait` pode mascarar erros** → Combinado com `kubectl rollout status` para diagnóstico claro.

## Migration Plan

1. Adicionar `scripts/resolve-image-ref.sh` e refatorar `publish-image.yml` para usá-lo (comportamento externo inalterado — validar com um run existente).
2. Adicionar `deploy-kubernetes.yml`, `docs/kubernetes-deploy.md` e `examples/github-actions/deploy-kubernetes.yml`.
3. No repo consumidor: configurar secrets/variáveis (`KUBECONFIG`, `INFRA_TOKEN`, `REGISTRY_*`, `INFRA_REPO`, `IMAGE_PULL_SECRET_NAME`) e adicionar o job `deploy` com `needs: publish`.
4. Rollback: reverter o commit no repo da aplicação (a tag imutável por SHA garante que o deploy anterior permanece disponível no registry).

## Open Questions

- O chart de referência deve ser versionado por tag do repo de infra ou sempre `main`? (Sugestão inicial: `main`, com opção de `ref` configurável.)
- Deve haver suporte a `values_file` adicional (ex.: `--values ./infra/<path>`)? (Provável necessidade futura.)
- O `imagePullSecret` deve ser recriado a cada deploy ou apenas quando as credenciais mudam? (Atual: recriado a cada deploy, idempotente.)
