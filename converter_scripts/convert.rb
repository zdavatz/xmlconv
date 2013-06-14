#!/usr/local/bin/ruby186/bin/ruby

require 'rubygems'

$: << '/usr/local/share/src/xmlconv/lib'

require 'lib/conversion/propharma_bdd'
require 'lib/conversion/pharmacieplus_bdd'
require 'lib/conversion/bdd_csv'
require 'lib/conversion/bdd_i2'

source_xml = ARGV.first

#reader = XmlConv::Conversion::ProPharmaBdd
reader = XmlConv::Conversion::PharmaciePlusBdd
#input  = reader.parse(File.read('input.txt'))
input  = reader.parse(File.read(source_xml))
model  = reader.convert(input)
#writer = XmlConv::Conversion::BddCsv
writer = XmlConv::Conversion::BddI2
output = writer.convert(model)

print output.to_s
