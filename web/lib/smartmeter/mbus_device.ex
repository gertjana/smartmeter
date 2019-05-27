defmodule Smartmeter.MBusDevice do

  defmodule Smartmeter.MBusDevice.Type do
    defstruct meter: "", description: ""
  end

	def to_device_type(nr) do
    case nr do
     2 -> %Smartmeter.MBusDevice.Type{meter: "Electricity", description: ""}
     3 -> %Smartmeter.MBusDevice.Type{meter: "Gas", description: ""}
     4 -> %Smartmeter.MBusDevice.Type{meter: "Heat meter", description: ""}
     6 -> %Smartmeter.MBusDevice.Type{meter: "Warm water", description: "(30°C - 90°C)"}
     7 -> %Smartmeter.MBusDevice.Type{meter: "Water", description: ""}
     8 -> %Smartmeter.MBusDevice.Type{meter: "Heat Cost Allocator", description: ""}
    10 -> %Smartmeter.MBusDevice.Type{meter: "Cooling", description: "(Volume measured at return temperature: outlet)"}
    11 -> %Smartmeter.MBusDevice.Type{meter: "Cooling", description: "(Volume measured at flow temperature: inlet)"}
    12 -> %Smartmeter.MBusDevice.Type{meter: "Heat meter", description: "(Volume measured at flow temperature: inlet)"}
    13 -> %Smartmeter.MBusDevice.Type{meter: "Combined Heating/Cooling", description: ""}
    21 -> %Smartmeter.MBusDevice.Type{meter: "Hot water", description: "(≥ 90°C)"}
    22 -> %Smartmeter.MBusDevice.Type{meter: "Cold water", description: ""}
    40 -> %Smartmeter.MBusDevice.Type{meter: "Waste water", description: ""}    end
  end
end



