# PromptBench

Test, compare, and improve your LLM prompts within your Rails application.

## Installation

> [!NOTE]
> This engine relies on ActiveJob, ActiveStorage, and [RubyLLM](https://github.com/crmne/ruby_llm). Make sure you have them installed and configured.

Add this line to your application's Gemfile:

```ruby
gem "prompt_bench"
```

And then execute:

```bash
$ bundle
$ rails g prompt_bench:install
```

This will create the migrations for the PromptBench models. So make sure you run:

```bash
$ rails db:migrate
```

And then mount the engine in your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  # ...

  mount PromptBench::Engine, at: "/prompt_bench"
end
```

![prompts](./assets/prompts.png)
![eval_results](./assets/eval_results.png)
![eval_result](./assets/eval_result.png)

## Usage

### Workflow

A typical workflow looks like this:

#### Create a prompt

A prompt represents an LLM prompt template with:

* Provider: see [available providers](https://github.com/crmne/ruby_llm/tree/main/lib/ruby_llm/providers)
* Model: see [available models](https://github.com/crmne/ruby_llm/blob/main/lib/ruby_llm/models.json). In case you're selecting a local provider (eg. Ollama), you can enter the model name in a text field.
* Instructions: optional, the system prompt.
* Message: message template.

Both the instructions and the message template can contain variables that will be replaced at runtime. To add variables, enclose them with braces. Eg: `{{name}}`.

> [!NOTE]
> In order to use a provider, you must have it configured in `config/initializer/ruby_llm.rb` as explained [here](https://rubyllm.com/configuration/#provider-configuration)

#### Add eval examples

When creating/editing a prompt you can add eval examples, where you can define:

* Variables: a JSON that contains the values to use when executing the prompt. Eg: `{ "name": "Patricio" }`
* Eval type: the evaluation criteria: exact match, contains, regex, or human review.
* Expected output: optional if the eval type is `human`
* Files: optional attachments.

#### Run evaluations

Once you have a prompt with its examples you can run the evaluations. This will enqueue a job that will create an eval result and run each eval example with the current prompt configuration.

The eval result will save the current prompt configuration for later analysis, such as the current provider/model, instructions, messages, variables, etc.

#### Analyze the results

You can view the accuracy, cost, and duration of the entire eval result and each individual prompt execution.

If you chose the human review eval type, it's now that you can review if an eval passed or not.

### Beyond a typical workflow

#### Using your data to create prompts/eval examples

Suppose you want to categorize images. You can have a prompt (eg. `image-categorization`) and then add your data to the eval set:

```ruby
prompt = PromptBench::Prompt.find_by slug: "image-categorization"

Image.where(category: nil).take(50).each do |image|
  eval_example = prompt.eval_examples.create eval_type: :human
  eval_example.files.attach image.attachment.blob
end
```

Then you iterate over the prompt trying to find the best configuration possible.

#### Using the prompt

You can use the prompt with your data and use the result to your convenience.

> [!NOTE]
> API not yet defined.

## Contributing

You can open an issue or a PR in GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
