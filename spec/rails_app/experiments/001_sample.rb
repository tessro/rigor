experiment "sample" do
  description "a sample experiment"
  identity :current_user

  treatment :control, :weight => 2
  treatment :test
end
