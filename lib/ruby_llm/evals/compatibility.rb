module RubyLLM
  module Evals
    module Compatibility
      module_function

      def with_params(chat, params)
        if chat.respond_to?(:with_provider_options)
          chat.with_provider_options(params)
        else
          chat.with_params(**params)
        end
      end

      def tokens(response, kind)
        if response.respond_to?(:tokens)
          response.tokens&.public_send(kind)
        else
          response.public_send("#{kind}_tokens")
        end
      end

      def model_id(response)
        response.respond_to?(:model_id) ? response.model_id : response.model
      end

      def price(model, kind)
        value = if model.respond_to?(:price)
          model.price(kind)
        else
          model.public_send("#{kind}_price_per_million")
        end
        value.to_f
      end

      def output_tokens(response)
        output = tokens(response, :output)
        return output unless Gem::Version.new(RubyLLM::VERSION) >= Gem::Version.new("2.0") && output

        output - tokens(response, :thinking).to_i
      end
    end
  end
end
