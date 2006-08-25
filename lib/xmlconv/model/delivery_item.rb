#!/usr/bin/env ruby
# DeliveryItem -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

require 'xmlconv/model/item'

module XmlConv
  module Model
    class DeliveryItem < Item
      attr_accessor :delivery_date
      def customer_id
        self.id_table['lieferantenartikel']
      end
      def ean13_id
        self.id_table['ean13']
      end
      def et_nummer_id
        self.id_table['et-nummer']
      end
      def pharmacode_id
        self.id_table['pharmacode']
      end
    end
  end
end
