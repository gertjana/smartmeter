defmodule Smartmeter.Series do
	
	defmodule CurrentEnergy do
	  use Instream.Series

	  series do
	    database    "smartmeter_measurements"
	    measurement "current_energy"

	    tag :energy
      tag :direction

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
end