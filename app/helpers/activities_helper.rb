module ActivitiesHelper

  # Takes an Array and makes a nested array with translated values 
  # for usage in options_for_select
  def prepare_options_for_select(array)
    new_array = Array.new
    array.each { |value|
      new_array.push([t(value), value])
    }
    new_array 
  end

end
