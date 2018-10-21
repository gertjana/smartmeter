# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Smartmeter.Repo.insert!(%Smartmeter.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Smartmeter.Repo.insert!(%Smartmeter.Config{key: "serial_enable", value: "false"})
Smartmeter.Repo.insert!(%Smartmeter.Config{key: "serial_baudrate", value: "115200"})
Smartmeter.Repo.insert!(%Smartmeter.Config{key: "serial_device", value: "/dev/ttyUSB0"})