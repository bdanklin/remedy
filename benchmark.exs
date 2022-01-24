Benchee.run(%{
  "api" => fn -> Remedy.API.get_application!() end
})
