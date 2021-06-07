json.total_count @app_results.total_count
json.current_page @app_results.current_page
json.total_pages @app_results.total_pages

json.app_results @app_results, partial: "result", as: :result
