defmodule MiniDiscord.Client do

  @doc """
  Point d'entrée principal du client.
  host : nom type 'xxxbore.pub'
  port : entier ex: 4040
  """

  def start(host, port) do
    connect_with_retry(host, port, 1)
  end

  defp connect_with_retry(host, port, attempt) do
    # TODO : Tenter :gen_tcp.connect avec les bonnes options
    case :gen_tcp.connect(host, port, [:binary, packet: :line, active: false]) do

    # TODO : Si {:ok, socket} -> handshake(socket) puis lancer les deux loops
      {:ok, socket} -> rencontre(socket)
        task_receive = Task.async(fn -> receive_loop(socket, host, port) end)
        task_send = Task.async(fn -> send_loop(socket) end)
        Task.await(task_receive, :infinity)
        Task.await(task_send, :infinity)

    # TODO : Si {:error, reason} ->
      {:error, reason} ->
        
    # TODO :   Afficher "Tentative #{attempt} échouée : #{reason}"
        IO.puts("Tentative #{attempt} échouée : #{reason}")
    # TODO :   Attendre 2 secondes avec :timer.sleep(2000)
        :timer.sleep(2000)
    # TODO :   Rappeler connect_with_retry(host, port, attempt + 1)
        connect_with_retry(host, port, attempt + 1)
    end
  end

  defp rencontre(socket) do
      # TODO : Lire les messages du serveur avec recv_print(socket)
      :gen_tcp.recv(socket, 0)

      # TODO : Envoyer le pseudo choisi par l'utilisateur avec IO.gets/1
      pseudo = IO.gets("Entrez votre pseudo : ")
      case valider_message(pseudo) do
        {:ok, valid_pseudo} -> :gen_tcp.send(socket, valid_pseudo)
        {:error, err} -> IO.puts("Erreur : #{err}"); rencontre(socket)
      end

      # TODO : Lire la suite (liste des salons)
      :gen_tcp.recv(socket, 0)

      # TODO : Envoyer le nom du salon
      salon = IO.gets("Entrez le nom du salon : ")
      case valider_message(salon) do
        {:ok, valid_salon} -> :gen_tcp.send(socket, valid_salon)
        {:error, err} -> IO.puts("Erreur : #{err}"); rencontre(socket)
      end


      # TODO : Lire la confirmation
      :gen_tcp.recv(socket, 0)
  end

  defp receive_loop(socket, host, port) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, msg} ->
        case valider_message(msg) do
            {:ok, valid_msg} -> IO.write(valid_msg)
            {:error, err} -> IO.puts("\nErreur message reçu : #{err}")
        end
        receive_loop(socket, host, port)

      {:error, reason} ->
        IO.puts("\nConnexion perdue (#{reason}). Reconnexion...")
        # TODO : Fermer proprement la socket avec :gen_tcp.close/1
        :gen_tcp.close(socket)
        # TODO : Rappeler connect_with_retry(host, port, 1)
        connect_with_retry(host, port, 1)
      end
  end

  defp send_loop(socket) do
      # TODO : Lire depuis le clavier avec IO.gets("")
      message = IO.gets("")
      # TODO : Envoyer au serveur avec :gen_tcp.send/2
      case valider_message(message) do
        {:ok, valid_msg} -> :gen_tcp.send(socket, valid_msg)
        {:error, err} -> IO.puts("Erreur : #{err}")
      end
      # TODO : Rappeler send_loop(socket)
      send_loop(socket)
  end

  defp valider_message(msg) do
    msg = String.trim(msg)
    
    cond do
      msg == "" -> {:error, "Message vide"}
      String.length(msg) > 500 -> {:error, "Message trop long (max 500 chars)"}
      String.match?(msg, ~r/[\\?<>]/) -> {:error, "Caractères non autorisés (\\, ?, <, >)"}
      true -> {:ok, msg <> "\n"}
    end
  end

end