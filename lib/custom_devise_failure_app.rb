# Use to prevent storing API locations that might get leaked
# After a signout/request bug
class CustomDeviseFailureApp < Devise::FailureApp
  def store_location!
    return if attempted_path =~ /api/

    super
  end
end
