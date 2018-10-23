defmodule Smartmeter.Series do
	
	defmodule ActivePower do
	  use Instream.Series

	  series do
	    database    "smartmeter_measurements"
	    measurement "current_power"

	    tag :power
      tag :direction
      tag :phase

	    field :value
	  end
	end

	defmodule TotalEnergy do
		use Instream.Series

		series do
	    database    "smartmeter_measurements"
	    measurement "total_energy"
		
      tag :energy
      tag :direction
      tag :tariff

	    field :value
		end
	end

  defmodule Voltage do
    use Instream.Series

    series do
      database    "smartmeter_measurements"
      measurement "voltage"
    
      tag :voltage
      tag :phase

      field :value
    end
  end

  defmodule Amperage do
    use Instream.Series

    series do
      database    "smartmeter_measurements"
      measurement "amperage"
    
      tag :amperage
      tag :phase

      field :value
    end
  end

  defmodule MbusMeasurement do
    use Instream.Series

    series do
      database    "smartmeter_measurements"
      measurement "mbus_measurement"

      tag :volume
      tag :channel

      field :value      
    end
  end
end