module Hancock
  class AnchoredTab < Hancock::Base
    #
    # type:        'sign_here',
    # label:       '{{recipient.name}} Signature',
    # offset:      [2, 100]
    # anchor_text: 'Owner 1 Signature', # defaults to label
    # page_number: default 1
    #

    ATTRIBUTES = [:type, :label, :offset, :anchor_text, :page_number]

    attr_accessor :type, :label, :offset, :anchor_text, :page_number

    validates :type, :label, :offset, presence: true 
    validates :offset, type: :array
    validates :page_number, default: 1
    validates :anchor_text, default: lambda{ |inst| inst.label }

    def initialize(attributes = {})
      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", attributes[attr])
      end
      self.validate!
    end
  end
end