namespace :siwapp do
  task :migrate_old_database do
    client = Mysql2::Client.new(
        :host  => "localhost",
        :database => "siwapp",
        :username => "root", 
        :password => "",
    )
    client.query("ALTER TABLE common DROP FOREIGN KEY common_recurring_invoice_id_common_id")
    client.query("ALTER TABLE common DROP FOREIGN KEY common_customer_id_customer_id")
    client.query("ALTER TABLE common DROP FOREIGN KEY common_series_id_series_id")
    client.query("ALTER TABLE item DROP FOREIGN KEY item_common_id_common_id")
    client.query("ALTER TABLE item DROP FOREIGN KEY item_product_id_product_id")
    client.query("ALTER TABLE item_tax DROP FOREIGN KEY item_tax_item_id_item_id")
    client.query("ALTER TABLE payment DROP FOREIGN KEY payment_invoice_id_common_id")
    client.query("ALTER TABLE sf_guard_group_permission DROP FOREIGN KEY sf_guard_group_permission_group_id_sf_guard_group_id")
    client.query("ALTER TABLE sf_guard_group_permission DROP FOREIGN KEY sf_guard_group_permission_permission_id_sf_guard_permission_id")
    client.query("ALTER TABLE sf_guard_remember_key DROP FOREIGN KEY sf_guard_remember_key_user_id_sf_guard_user_id")
    client.query("ALTER TABLE sf_guard_user_group DROP FOREIGN KEY sf_guard_user_group_group_id_sf_guard_group_id")
    client.query("ALTER TABLE sf_guard_user_group DROP FOREIGN KEY sf_guard_user_group_user_id_sf_guard_user_id")
    client.query("ALTER TABLE sf_guard_user_permission DROP FOREIGN KEY sf_guard_user_permission_permission_id_sf_guard_permission_id")
    client.query("ALTER TABLE sf_guard_user_permission DROP FOREIGN KEY sf_guard_user_permission_user_id_sf_guard_user_id")
    client.query("ALTER TABLE sf_guard_user_profile DROP FOREIGN KEY sf_guard_user_profile_sf_guard_user_id_sf_guard_user_id")

    client.query("DROP TABLE sf_guard_group")
    client.query("DROP TABLE sf_guard_group_permission")
    client.query("DROP TABLE sf_guard_permission")
    client.query("DROP TABLE sf_guard_remember_key")
    client.query("DROP TABLE sf_guard_user")
    client.query("DROP TABLE sf_guard_user_group")
    client.query("DROP TABLE sf_guard_user_permission")
    client.query("DROP TABLE sf_guard_user_profile")
    client.query("DROP TABLE migration_version")

    client.query("ALTER TABLE common CHANGE `id` `id` INT NOT NULL AUTO_INCREMENT")
    client.query("ALTER TABLE common CHANGE recurring_invoice_id recurring_invoice_id INT")
    client.query("ALTER TABLE common CHANGE series_id serie_id INT")
    client.query("ALTER TABLE common CHANGE customer_id customer_id INT")
    client.query("ALTER TABLE common CHANGE invoicing_address invoicing_address TEXT")
    client.query("ALTER TABLE common CHANGE shipping_address shipping_address TEXT")
    client.query("ALTER TABLE common CHANGE terms terms TEXT")
    client.query("ALTER TABLE common CHANGE notes notes TEXT")

    client.query("ALTER TABLE customer CHANGE `id` `id` INT NOT NULL AUTO_INCREMENT")
    client.query("ALTER TABLE customer CHANGE invoicing_address invoicing_address TEXT")
    client.query("ALTER TABLE customer CHANGE shipping_address shipping_address TEXT")

    client.query("ALTER TABLE item CHANGE `id` `id` INT NOT NULL AUTO_INCREMENT")
    client.query("ALTER TABLE item CHANGE common_id common_id INT")
    client.query("ALTER TABLE item CHANGE product_id product_id INT")

    client.query("ALTER TABLE item_tax CHANGE item_id item_id INT")
    client.query("ALTER TABLE item_tax CHANGE tax_id tax_id INT")

    client.query("ALTER TABLE payment CHANGE `id` `id` INT NOT NULL AUTO_INCREMENT")
    client.query("ALTER TABLE payment CHANGE invoice_id invoice_id INT")
    client.query("ALTER TABLE payment CHANGE notes notes TEXT")

    client.query("ALTER TABLE product CHANGE `id` `id` INT NOT NULL AUTO_INCREMENT")
    client.query("ALTER TABLE product CHANGE description description TEXT")

    client.query("ALTER TABLE property CHANGE value value TEXT")

    client.query("ALTER TABLE series CHANGE `id` `id` INT NOT NULL AUTO_INCREMENT")

    client.query("ALTER TABLE tag CHANGE `id` `id` INT NOT NULL AUTO_INCREMENT")

    client.query("ALTER TABLE tagging CHANGE `id` `id` INT NOT NULL AUTO_INCREMENT")
    client.query("ALTER TABLE tagging CHANGE tag_id tag_id INT")
    client.query("ALTER TABLE tagging CHANGE taggable_id taggable_id INT")

    client.query("ALTER TABLE tax CHANGE `id` `id` INT NOT NULL AUTO_INCREMENT")

    client.query("ALTER TABLE template CHANGE `id` `id` INT NOT NULL AUTO_INCREMENT")
    client.query("ALTER TABLE template CHANGE template template TEXT")

    # Table renaming according to rails convention
    client.query("RENAME TABLE common TO commons")
    client.query("RENAME TABLE customer TO customers")
    client.query("RENAME TABLE item TO items")
    client.query("RENAME TABLE payment TO payments")
    client.query("RENAME TABLE product TO products")
    client.query("RENAME TABLE property TO properties")
    client.query("RENAME TABLE template TO templates")
    client.query("RENAME TABLE tax TO taxes")
    client.query("RENAME TABLE item_tax TO items_taxes")

    client.query("CREATE TABLE `schema_migrations` (
       `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
       UNIQUE KEY `unique_schema_migrations` (`version`)
       ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci")
    client.query("INSERT INTO `schema_migrations` VALUES ('20150117155103')")

  end
end
