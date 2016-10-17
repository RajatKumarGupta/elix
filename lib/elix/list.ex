defmodule Elix.List do

  @namespace "lists"
  @redis_client Application.get_env(:elix, :redis_client)
  @process :redix

  def all do
    @redis_client.command!(@process, ["LRANGE", lists_key, 0, -1])
  end

  def create(list_name) do
    @redis_client.command!(@process, ["RPUSH", lists_key, list_name])
  end

  def delete(list_name) do
    @redis_client.command!(@process, ["LREM", lists_key, 0, list_name])
    clear_items(list_name)
  end

  def get_items(list_name) do
    @redis_client.command!(@process, ["LRANGE", list_key(list_name), 0, -1])
  end

  def add_item(list_name, item_name) do
    @redis_client.command!(@process, ["RPUSH", list_key(list_name), item_name])
  end

  def delete_item(list_name, item_name) do
    @redis_client.command!(@process, ["LREM", list_key(list_name), 0, item_name])
  end

  def clear_items(list_name) do
    @redis_client.command!(@process, ["DEL", list_key(list_name)])
  end

  defp lists_key do
    @namespace
  end

  defp list_key(list_name) do
    "#{lists_key}:#{hex_digest(list_name)}"
  end

  defp hex_digest(name) do
    name
    |> md5_hash
    |> Base.encode16
    |> String.downcase
  end

  defp md5_hash(hashable) do
    :crypto.hash(:md5, hashable)
  end
end
