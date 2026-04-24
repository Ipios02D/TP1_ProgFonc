# MiniDiscord

Q1. Pourquoi utilise-t-on Process.monitor/1 dans handle_call({:rejoindre}) ? 

  On utilise Process.monitor/1 pour surveiller le processus mis en paramètre, cela nous envoie un message lorsque le processus s'arrete.

Q2. Que se passe-t-il si on n'implémente pas handle_info({:DOWN, ...}) ? 
  Les pid des clients deconnectés ne serait pas enlevés de la liste state.clients donc on essaie de leurs envoyés les messages du salon.

Q3. Quelle est la différence entre handle_call et handle_cast ? Pourquoi broadcast est un cast ?
  handle_call est synchrone: l’appelant attend une réponse du serveur. handle_cast est asynchrone: l’appelant envoie le message et continue sans attendre. broadcast utilise un cast car on n'a pas besoin de réponse, cela permet au client de continuer sans attendre le serveur.

2-4. Le salon redémarre-t-il après le kill ? Pourquoi ? 
  Oui, le salon redémarre après un kill, parce qu’il est surveillé par un superviseur. Quand un processus enfant meurt, le superviseur le relance automatiquement pour garder le système en vie.

2-5. Quelle est la différence entre les stratégies :one_for_one et :one_for_all ?
  one_for_one : si un enfant crash, seul cet enfant est redémarré.
  one_for_all : si un enfant crash, tous les enfants du superviseur sont arrêtés puis redémarrés ensemble.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mini_discord` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mini_discord, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/mini_discord>.

