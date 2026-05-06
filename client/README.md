# Client

Si on execute coté serveur : "Process.whereis(MiniDiscord.ChatServer) |> Process.exit(:kill)"
alors du coté client on se retrouve déconnecté

Fonction start du début :
def start(host, port) do
      # TODO : Connecter la socket avec :gen_tcp.connect/3
      case :gen_tcp.connect(host, port, [:binary, packet: :line, active: false]) do

      # TODO : Options : [:binary, packet: :line, active: false]

      # TODO : En cas d'erreur {:error, reason} -> afficher l'erreur et quitter
        {:error, reason} -> IO.puts("Erreur de connexion : #{reason}")
        :init.stop()

      # TODO : Appeler la fonction rencontre(socket) pour le pseudo et le salon
        {:ok, socket} -> rencontre(socket)

      # TODO : Lancer le receiver dans un Task.async : fn -> receive_loop(socket) end
          task_receive = Task.async(fn -> receive_loop(socket) end)

      # TODO : Lancer le sender dans un Task.async : fn -> send_loop(socket) end
          task_send = Task.async(fn -> send_loop(socket) end)

      # TODO : Attendre les deux tasks avec Task.await/2 (timeout: :infinity)
          Task.await(task_receive, :infinity)
          Task.await(task_send, :infinity)
    end
  end

Fonction receive du début :
defp receive_loop(socket) do
      # TODO : Appeler :gen_tcp.recv(socket, 0) — bloquant jusqu'à réception
      case :gen_tcp.recv(socket, 0) do

      # TODO : Si {:ok, msg} -> afficher avec IO.write/1 et rappeler receive_loop
        {:ok, msg} -> IO.write(msg); receive_loop(socket)

      # TODO : Si {:error, _} -> afficher "Déconnecté" et arrêter
        {:error, _} -> IO.puts("Déconnecté"); :init.stop()
      end

2.3 Qu'apporterait la gestion du suivi de processus, redémarrage automatique par rapport à votre code ?

La gestion du suivi de processus de processus avec OTP permet de ne plus faire de reconnexion manuellement, c'est le superviseur qui s'en occupe. Il y a aussi un aspect de sécurité : on évite de boucler quand le serveur est éteint et on arrete l'envoi de message quand il n'y a plus de reception.

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:client, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/client>.

