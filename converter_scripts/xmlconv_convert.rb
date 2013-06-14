# /usr/bin/env ruby
# xmlconv.converter.rb -- 24.02.2011 -- mhatakeyama@ywesee.com

def usage
  print <<EOF
  usage:
    ruby #{__FILE__} -i [input file]

  options:
    -i [input file]  (default: input.csv)
    -o [output file] (default: output.csv)
    -k [Kunden file] (default: Kunden.txt)
    -a [Artikel file](default: Artikel.txt)
    -h help
EOF
  exit
end

# Analyze options
if ARGV[0] == '-h'
  usage  
end
begin
  options = Hash[*ARGV]
rescue ArgumentError
  usage
end
input_file   = options['-i'] ||= 'input.csv'
output_file  = options['-o'] ||= 'output.csv'
kunden_file  = options['-k'] ||= 'Kunden.txt'
artikel_file = options['-a'] ||= 'Artikel.txt'

unless File.exist?(input_file)
  print "Input file (#{input_file}) could not found.\n\n"
  usage
end
unless File.exist?(kunden_file)
  print "Kunden.txt (#{kunden_file}) could not found.\n\n"
  usage
end
unless File.exist?(artikel_file)
  print "Atrikel.txt (#{artikel_file}) cannot be found.\n\n"
  usage
end

# Sort by date
lines = []
File.readlines(input_file).each do |line|
  x = line.split(/,/)
  date = x[2].match(/(\d\d)(\d\d)(20\d\d)/).to_a
  new_date = date[3] + date[2] + date[1]
  x[2] = new_date
  lines << x.join(',') 
end
lines.sort!.reverse!

# Load Kunden.txt and Artikel.txt
kunden = [{}, {}]
File.readlines(kunden_file).each do |line|
  x = line.split(/\t/)
  #print x[0], ",", x[1], ",", x[6], "\n"
  kunden[0][x[0]] = x[6]
  kunden[1][x[1]] = x[6]
end

artikel = [{}, {}]
price   = [{}, {}]
File.readlines(artikel_file).each do |line|
  x = line.split(/\t/)
  #print x[4], ",", x[3], ",", x[2], "\n"
  artikel[0][x[4]] = x[2]
  artikel[1][x[3]] = x[2]
  #print x[5], "\n"
  price[0][x[4]]   = x[5]
  price[1][x[3]]   = x[5]
end

# Add Kunden and Artikel info
kunden_missing_list = []
artikel_missing_list = []
last = 0
open(output_file, "w") do |out|
# Header
out.print "Kundennr., Kunde, Artikelnr., EAN Code, Produkt, Menge, Preis, Bestelldatum\n"
lines.each_with_index do |line,i|
  x = line.split(/,/)

  # Search Kunden Name
  kunden_name = ""
  kunden.each do |k|
    if k.keys.include?(x[1])
      kunden_name = k[x[1]]
      break
    end
  end
  if kunden_name == "" or kunden_name == nil
    kunden_missing_list << x[1]
#    warn "Kunden ID (#{x[1]}) could not be found."
  end

  # Search Produkt Name
  artikel_name = ""
  artikel.each do |a|
    if a.keys.include?(x[4])
      artikel_name = a[x[4]]
      break
    end
  end
  if artikel_name == "" or artikel_name == nil
    artikel_missing_list << x[4]
#    warn "Artikel ID (#{x[4]}) could not be found."
  end

  # Calc price
  total_price = 0.0
  price.each do |pr|
    if pr.keys.include?(x[4])
      total_price = pr[x[4]].to_f * x[7].to_f
      break
    end
  end

  # Output
  x.map!{|z| z || ""}
  artikel_name ||=""
  kunden_name ||=""
  total_price ||=""
  out.print x[1] + ",\"" + kunden_name + "\"," +\
      x[4] + "," + x[5] + ",\"" + artikel_name + "\"," + \
      x[7] + "," + total_price.to_s + "," + x[2] + "\n"

  if last != (i*10)/lines.length
    last = (i*10)/lines.length
    $stderr.print "." 
  end
end
end
$stderr.print "done.\n\n"

# Report missing numbers
unless kunden_missing_list.empty?
  print "The following Kunden IDs were not found:\n"
  print kunden_missing_list.uniq.sort.join(","), "\n\n"
end
unless artikel_missing_list.empty?
  print "The following Artikel IDs were not found:\n"
  print artikel_missing_list.uniq.sort.join(","), "\n\n"
end


