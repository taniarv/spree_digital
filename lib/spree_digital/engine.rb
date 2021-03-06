module SpreeDigital
  class Engine < Rails::Engine
    isolate_namespace Spree
    engine_name 'spree_digital'

    config.autoload_paths += %W(#{config.root}/lib)

    initializer 'spree_digital.preferences', before: :load_config_initializers do
      SpreeDigital::Config = Spree::DigitalConfiguration.new
    end

    initializer 'spree_digital.ability', :after => 'spree.register.ability' do
      Spree::Ability.register_ability(Spree::DigitalAbility)
    end

    initializer "spree.register.digital_shipping", :after => 'spree.register.calculators' do |app|
      app.config.spree.calculators.shipping_methods << Spree::Calculator::Shipping::DigitalDelivery
    end

    initializer 'spree_digital.custom_spree_splitters', :after => 'spree.register.stock_splitters' do |app|
      app.config.spree.stock_splitters << Spree::Stock::Splitter::Digital
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
