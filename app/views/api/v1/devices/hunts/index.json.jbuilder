json.total_count @hunts.total_count
json.current_page @hunts.current_page
json.total_pages @hunts.total_pages

json.hunts @hunts, partial: "hunt", as: :hunt, locals: { device: @device }
