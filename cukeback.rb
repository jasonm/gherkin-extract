require 'rubygems'
require 'gherkin'
require 'rspec' # ugh, turnip
require 'turnip'

# http://rosettacode.org/wiki/Longest_common_subsequence#Ruby
def lcs(a, b)
  lengths = Array.new(a.size+1) { Array.new(b.size+1) { 0 } }
  # row 0 and column 0 are initialized to 0 already
  a.split('').each_with_index { |x, i|
    b.split('').each_with_index { |y, j|
      if x == y
        lengths[i+1][j+1] = lengths[i][j] + 1
      else
        lengths[i+1][j+1] = \
          [lengths[i+1][j], lengths[i][j+1]].max
      end
    }
  }
  # read the substring out from the matrix
  result = ""
  x, y = a.size, b.size
  while x != 0 and y != 0
    if lengths[x][y] == lengths[x-1][y]
      x -= 1
    elsif lengths[x][y] == lengths[x][y-1]
      y -= 1
    else
      # assert a[x-1] == b[y-1]
      result << a[x-1]
      x -= 1
      y -= 1
    end
  end
  result.reverse
end


# Get the whole step
# Maybe use Scenarios and get their raw text, instead?
module Turnip
  class Builder
    class Step
      def to_s
        # Idea: Should we be able to be insensitive to keywords, and then reconstruct them from the original example?
        "#{@raw.keyword}#{name}"
      end
    end
  end
end

content = $<.read

builder = Turnip::Builder.new
formatter = Gherkin::Formatter::TagCountFormatter.new(builder, {})
parser = Gherkin::Parser::Parser.new(formatter, true, "root", false)
parser.parse(content, nil, 0)

feature = builder.features.first
shared_steps = feature.scenarios.first.steps.map { |step| step.to_s }.join("\n")

puts shared_steps
puts "Analyzing #{feature.scenarios.size} scenarios..."

feature.scenarios.each_with_index do |scenario, index|
  scenario_steps = scenario.steps.map { |step| step.to_s }.join("\n")

  puts
  puts "Scenario #{index+1}:"
  puts scenario_steps
  puts

  shared_steps = lcs(shared_steps, scenario_steps)

  puts "Finished scenario #{index+1}"
  # if index == 2
    puts "Shared steps so far:"
    puts shared_steps
    puts
  #   exit
  # end
end

puts "Final shared background:"
puts shared_steps
