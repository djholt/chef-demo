name "base"
run_list "recipe[apt]", "recipe[ruby_build]", "recipe[rbenv::system]"
override_attributes "rbenv" => {
  "rubies" => ["1.9.3-p125"],
  "global" => "1.9.3-p125",
  "gems" => { "1.9.3-p125" => [{ "name" => "bundler" }] }
}
