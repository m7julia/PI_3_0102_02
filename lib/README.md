# 🌿 Como criar e usar sua própria branch (Git) (TEMPORÁRIO)

Este guia mostra o passo a passo para cada integrante do grupo trabalhar no projeto sem conflitos.

---

## 🚀 1. Abrir o terminal na pasta do projeto

Certifique-se de estar dentro do projeto:

```bash
cd caminho/do/projeto
```

---

## 🔄 2. Atualizar o projeto

Antes de tudo, atualize seu projeto com a versão mais recente:

```bash
git checkout main
git pull origin main
```

---

## 🌿 3. Criar sua própria branch

Cada integrante deve criar uma branch com seu nome:

```bash
git checkout -b feature/mundo-seunome
```

### 📌 Exemplo:

```bash
git checkout -b feature/mundo-luis
```

---

## ☁️ 4. Enviar sua branch para o GitHub

```bash
git push origin feature/mundo-seunome
```

---

## 🔁 5. Fluxo de trabalho diário

Sempre que for programar:

### ✔️ Entrar na sua branch

```bash
git checkout feature/mundo-seunome
```

### ✔️ Atualizar com a main

```bash
git pull origin main
```

### ✔️ Fazer suas alterações no código

---

## 💾 6. Salvar alterações (commit)

```bash
git add .
git commit -m "mensagem explicando o que foi feito"
```

### 📌 Exemplo:

```bash
git commit -m "cria tela inicial do mundo do Luis"
```

---

## ☁️ 7. Enviar alterações (push)

```bash
git push origin feature/mundo-seunome
```

---

## ⚠️ Regras importantes

* ❌ NÃO trabalhar na branch `main`
* ✔️ Sempre usar sua própria branch
* ✔️ Trabalhar apenas na sua pasta (`lib/features/seu_mundo`)
* ✔️ Fazer commits frequentes
* ✔️ Sempre dar `git pull origin main` antes de começar

---

## 🧠 Resumo rápido

```bash
git checkout main
git pull origin main
git checkout -b feature/mundo-seunome
git push origin feature/mundo-seunome

# Depois no dia a dia:
git checkout feature/mundo-seunome
git pull origin main
git add .
git commit -m "mensagem"
git push origin feature/mundo-seunome
```

---

## 🎯 Objetivo

Cada integrante trabalha de forma isolada, evitando conflitos e mantendo o projeto organizado.
