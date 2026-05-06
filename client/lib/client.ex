defmodule MiniDiscord.Client do

  @doc """
  Point d'entrée principal du client.
  host : nom type 'xxxbore.pub'
  port : entier ex: 4040
  """
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

  defp rencontre(socket) do
      # TODO : Lire les messages du serveur avec recv_print(socket)
      :gen_tcp.recv(socket, 0)

      # TODO : Envoyer le pseudo choisi par l'utilisateur avec IO.gets/1
      pseudo = IO.gets("Entrez votre pseudo : ")
      :gen_tcp.send(socket, pseudo)

      # TODO : Lire la suite (liste des salons)
      :gen_tcp.recv(socket, 0)

      # TODO : Envoyer le nom du salon
      salon = IO.gets("Entrez le nom du salon : ")
      :gen_tcp.send(socket, salon)

      # TODO : Lire la confirmation
      :gen_tcp.recv(socket, 0)
  end

  defp receive_loop(socket) do
      # TODO : Appeler :gen_tcp.recv(socket, 0) — bloquant jusqu'à réception
      case :gen_tcp.recv(socket, 0) do

      # TODO : Si {:ok, msg} -> afficher avec IO.write/1 et rappeler receive_loop
        {:ok, msg} -> IO.write(msg); receive_loop(socket)

      # TODO : Si {:error, _} -> afficher "Déconnecté" et arrêter
        {:error, _} -> IO.puts("Déconnecté"); :init.stop()
      end
  end

  defp send_loop(socket) do
      # TODO : Lire depuis le clavier avec IO.gets("")
      message = IO.gets("")
      # TODO : Envoyer au serveur avec :gen_tcp.send/2
      :gen_tcp.send(socket, message)
      # TODO : Rappeler send_loop(socket)
      send_loop(socket)
  end

end