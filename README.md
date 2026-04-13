# 🌳 A Árvore da Harmonia

> Um aplicativo interativo e 100% offline focado em gamificar atitudes positivas e incentivar o tempo de qualidade em família, promovendo a inteligência emocional no desenvolvimento infantil.

Este projeto é desenvolvido como **Atividade Extensionista** para a disciplina de Desenvolvimento de Software (1º Semestre de 2026), do curso de Ciência da Computação.

---

## 📱 Visão Geral
Em vez de focar em telas viciantes ou sistemas punitivos, **A Árvore da Harmonia** utiliza o reforço positivo lúdico. Cada atitude boa da criança (como ajudar em casa ou resolver um conflito pacificamente) se transforma em uma folha na árvore. Ao atingir a meta semanal, um "Fruto Dourado" é gerado, revelando uma recompensa real em família (ex: "Noite da Pizza").

O aplicativo foi desenhado para garantir **privacidade total**. Não há necessidade de criação de contas ou conexão com a internet; todos os dados ficam salvos localmente no dispositivo da família.

---

## ✨ Funcionalidades Principais

* **Ciclo Semanal Gamificado:** Adição de folhas interativas diretamente nos galhos da árvore.
* **Cenário Dinâmico:** A imagem de fundo e a iluminação da árvore mudam automaticamente de acordo com o horário do celular (Manhã, Tarde, Entardecer e Noite).
* **Área do Mestre (Modo Pais):** Um painel de controle protegido por PIN numérico para definir a meta de folhas da semana e a recompensa final.
* **Interação com Sensores:** Integração com o acelerômetro do aparelho para a mecânica de "agitar o celular" no domingo à noite, simulando a chegada do outono e resetando a árvore para a próxima semana.
* **Animações Lúdicas:** Feedbacks visuais suaves para a colocação das folhas e nascimento do Fruto Dourado.

---

## 🛠️ Tecnologias e Pacotes Utilizados

O projeto está sendo desenvolvido em **Flutter** (Dart), garantindo um aplicativo nativo para Android com alta fluidez nas animações.

* **[Flutter / Dart]** - Framework principal de UI.
* **[Hive] ou [SharedPreferences]** - Para armazenamento local de dados (Contador de folhas, metas, prêmio e PIN).
* **[sensors_plus]** - Para capturar movimentos do celular (agitar).
* **[lottie]** - Para renderização das animações do Fruto Dourado e das folhas caindo.

---

## 🚀 Como Executar o Projeto

Certifique-se de ter o Flutter SDK e o Android Studio instalados na sua máquina.

1. Clone o repositório:
```bash
git clone [https://github.com/smartielo/arvore_da_harmonia.git](https://github.com/smartielo/arvore_da_harmonia.git)
```

2. Acesse a pasta do projeto:
```bash
cd arvore_da_harmonia
```

3. Baixe as dependências:
```bash
flutter pub get
```

4. Execute o aplicativo (em um emulador ou dispositivo físico):
```bash
flutter run
```

## Equipe de Desenvolvimento e Créditos
 - Docente Responsável: Prof. Dr. Elvio Gilberto da Silva

### Desenvolvedores (Frontend e Backend):

- Gabriel Furlaneto de Luiz
- Gabriel Martielo
- João Vitor Diniz


#### Apoio: Coordenadoria de Extensão.
