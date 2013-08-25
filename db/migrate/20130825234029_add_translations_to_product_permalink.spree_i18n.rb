# This migration comes from spree_i18n (originally 20130518224827)
class AddTranslationsToProductPermalink < ActiveRecord::Migration
  def up
    fields = { :permalink => :string }
    Spree::Product.add_translation_fields!(fields, { :migrate_data => true })
  end

  def down
  end
end
