defmodule Elix.Responders.Lists do
  @moduledoc """
  Commands to create, update, and delete one-dimensional lists and their items.
  """

  use Hedwig.Responder
  alias Hedwig.Message
  alias Elix.Lists

  @usage """
  show lists - Displays all lists
  """
  respond ~r/show lists\Z/i, msg do
    reply(msg, render_items(Lists.all))
  end

  @usage """
  create list <name> - Creates a new list with name
  """
  respond ~r/create list (.+)/i, %Message{matches: %{1 => list_name}} = msg do
    Lists.create(list_name)
    reply(msg, render_items(Lists.all))
  end

  @usage """
  show list <list> - Displays the contents of a list by name or number
  """
  respond ~r/show list (.+)/i, %Message{matches: %{1 => list_id}} = msg do
    list_name = parse_list_identifier(list_id)

    reply(msg, render_list(list_name))
  end

  @usage """
  delete list <list> - Deletes a list by name or number
  """
  respond ~r/delete list (.+)/i, %Message{matches: %{1 => list_id}} = msg do
    list_name = parse_list_identifier(list_id)
    Lists.delete(list_name)

    reply(msg, render_items(Lists.all))
  end

  @usage """
  clear list <list> - Deletes all items from a list by name or number
  """
  respond ~r/clear list (.+)/i, %Message{matches: %{1 => list_id}} = msg do
    list_name = parse_list_identifier(list_id)

    Lists.clear_items(list_name)
    reply(msg, render_list(list_name))
  end

  @usage """
  add <item> to <list> - Adds an item to a list by name or number
  """
  respond ~r/add (.+) to (.+)/i, %Message{matches: %{1 => item_name, 2 => list_id}} = msg do
    list_name = parse_list_identifier(list_id)

    Lists.add_item(list_name, item_name)
    reply(msg, render_list(list_name))
  end

  @usage """
  delete <item> from <name> - Deletes an item from a list by name or number
  """
  respond ~r/delete (.+) from (.+)/i, %Message{matches: %{1 => item_id, 2 => list_id}} = msg do
    list_name = parse_list_identifier(list_id)
    item_name = parse_item_identifier(item_id, list_name)

    Lists.delete_item(list_name, item_name)
    reply(msg, render_list(list_name))
  end

  defp parse_list_identifier(list_id) do
    try do
      list_id |> String.to_integer |> Lists.get_name
    rescue
      _error in ArgumentError -> list_id
    end
  end

  defp parse_item_identifier(item_id, list_name) do
    try do
      item_id |> String.to_integer |> Lists.get_item_name(list_name)
    rescue
      _error in ArgumentError -> item_id
    end
  end
  
  defp render_items(list) when is_list(list) do
    list
    |> Enum.with_index(1)
    |> Enum.map(fn({item, index}) -> "#{index}. #{item}\n" end)
    |> Enum.join
  end

  defp render_list(list_name) when is_binary(list_name) do
    "**#{list_name}**\n\n#{render_items(Lists.get_items(list_name))}"
  end
end
