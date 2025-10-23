class CreateRubyLLMEvalsPrompts < ActiveRecord::Migration[7.0]
  def change
    create_table :ruby_llm_evals_prompts do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :provider, null: false
      t.string :model, null: false
      t.float :temperature
      t.json :params
      t.json :tools
      t.string :schema
      t.json :schema_other
      t.text :instructions
      t.text :message

      t.timestamps
    end
    add_index :ruby_llm_evals_prompts, :name, unique: true
    add_index :ruby_llm_evals_prompts, :slug, unique: true
  end
end
