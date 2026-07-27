# Controle de Núcleos e Comissões

Aplicativo web single-file (HTML/CSS/JS) para acompanhar o andamento das
ações e pendências de cada núcleo e comissão do **Hospital Maternidade
São Vicente de Paulo** — do Serviço de Qualidade Hospitalar.

**Link em produção:** https://prisato.github.io/status-nucleos-comissoes/

## Arquivo principal
`index.html` — contém toda a interface, estilos e lógica do app (não há
build step; é servido como está).

## Funcionalidades
- **Painel** com indicadores (total, OK, pendentes, em atraso, ações em
  aberto), situação geral e lista de núcleos/comissões com ações pendentes.
- **Lista** de núcleos e comissões com busca e filtros; cada card mostra
  situação, categoria, presidente, periodicidade, quórum e status da ata.
- **Detalhe** de cada núcleo/comissão: lista de ações/pendências (com
  status, responsável, datas e observação), dados do cadastro, membros
  (nomes um por linha, contagem automática) e legislação base.
- Selo de **quórum** colorido (verde = atinge maioria simples; amarelo =
  não atinge; vermelho = ata pendente).
- **Backup** (exportar) e **Importar** em JSON.

## Papéis de acesso
- **Login** por e-mail/senha (Supabase Auth). Autocadastro liberado.
- **Editores**: apenas os e-mails listados na tabela `ncom_admins` podem
  criar/editar/excluir. Os demais usuários entram em modo **somente
  leitura** (veem tudo, sem botões de edição).
- **Dados compartilhados**: todos veem os mesmos dados, sincronizados
  entre dispositivos (não é mais localStorage por aparelho).

## Backend (Supabase)
Reaproveita o mesmo projeto Supabase das demais auditorias, mas em
**tabelas próprias** (`ncom_store`, `ncom_admins`), isoladas por RLS:
- `ncom_store` (key/value): qualquer autenticado **lê**; só editores **gravam**.
- `ncom_admins` (lista de e-mails editores): gerida só pelo SQL Editor.

### Configuração inicial (rodar 1 vez)
No painel do Supabase → **SQL Editor** → cole e rode o conteúdo de
[`supabase_schema.sql`](supabase_schema.sql). Para trocar/adicionar
editores, edite a tabela `ncom_admins` (por ali mesmo) e rode de novo.

## Hospedagem
GitHub Pages, deploy automático a cada push na branch `main`.
