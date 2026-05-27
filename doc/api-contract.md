# FinTrack — Contrato da API (Módulo 09)

Este documento define o contrato REST que o app FinTrack irá consumir.
No Módulo 09, o backend ainda pode ser **fictício** (API pública ou servidor local).
No Módulo 10, este contrato será implementado no backend.

## Base URL

- Produção (exemplo): `https://api.fintrack.example.com`
- Desenvolvimento local (exemplo): `http://localhost:3000`

## Convenções

- JSON em `snake_case`.
- Datas em ISO 8601 (`toIso8601String()` / `DateTime.parse`).
- Códigos HTTP:
  - 200 OK: leitura/atualização com corpo
  - 201 Created: criação com corpo
  - 204 No Content: deleção/atualização sem corpo
  - 400 Bad Request: payload inválido
  - 401 Unauthorized: sem autenticação / sessão expirada
  - 403 Forbidden: sem permissão
  - 404 Not Found: recurso não existe
  - 409 Conflict: conflito (ex.: duplicado)
  - 422 Unprocessable Entity: regras de negócio violadas
  - 500 Internal Server Error: erro inesperado

## Autenticação (futuro)

> O app atual faz login local por e-mail. Quando o backend existir, a autenticação pode seguir este padrão.

### POST /auth/login

Request:

```json
{ "email": "demo@fintrack.com" }
```

Response 200:

```json
{
  "token": "<jwt>",
  "user": { "id": 1, "name": "Demo", "email": "demo@fintrack.com" }
}
```

## Usuários

### GET /users/{user_id}

Response 200:

```json
{
  "id": 1,
  "name": "Demo",
  "email": "demo@fintrack.com",
  "currency_code": "BRL",
  "created_at": "2026-05-27T12:00:00.000Z",
  "updated_at": null
}
```

### GET /users?email={email}

Busca usuário por e-mail (usado para login HTTP-first no app).

Response 200:

```json
{
  "id": 1,
  "name": "Demo",
  "email": "demo@fintrack.com",
  "currency_code": "BRL",
  "created_at": "2026-05-27T12:00:00.000Z",
  "updated_at": null
}
```

Response 404:

Sem corpo, ou uma mensagem de erro.

### PUT /users/{user_id}

Cria/atualiza um usuário (semântica de PUT).

Request:

```json
{
  "id": 1,
  "name": "Demo",
  "email": "demo@fintrack.com",
  "currency_code": "BRL",
  "created_at": "2026-05-27T12:00:00.000Z",
  "updated_at": null
}
```

Response 200/201:

```json
{
  "id": 1,
  "name": "Demo",
  "email": "demo@fintrack.com",
  "currency_code": "BRL",
  "created_at": "2026-05-27T12:00:00.000Z",
  "updated_at": null
}
```

## Transações

### GET /users/{user_id}/transactions

Retorna todas as transações do usuário, ordenadas por `created_at` desc.

Response 200:

```json
[
  {
    "id": "1716820000000",
    "amount": 42.5,
    "category": "Alimentação",
    "description": "Almoço",
    "created_at": "2026-05-27T12:00:00.000Z"
  }
]
```

### GET /users/{user_id}/transactions/{id}

Response 200 (objeto único igual ao da lista)

### PUT /users/{user_id}/transactions/{id}

Substitui a transação inteira (semântica de PUT).

Request:

```json
{
  "id": "1716820000000",
  "amount": 42.5,
  "category": "Alimentação",
  "description": "Almoço",
  "created_at": "2026-05-27T12:00:00.000Z"
}
```

Response 200:

```json
{
  "id": "1716820000000",
  "amount": 42.5,
  "category": "Alimentação",
  "description": "Almoço",
  "created_at": "2026-05-27T12:00:00.000Z"
}
```

### DELETE /users/{user_id}/transactions/{id}

Response 204 (No Content)
