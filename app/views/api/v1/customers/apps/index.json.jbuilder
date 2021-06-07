json.total_count @apps.total_count
json.current_page @apps.current_page
json.total_pages @apps.total_pages

json.apps @apps, partial: "app", as: :app
