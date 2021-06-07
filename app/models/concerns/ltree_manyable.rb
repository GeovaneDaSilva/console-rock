# Used to define and lookup relations via a record's ltree
module LtreeManyable
  extend ActiveSupport::Concern

  class_methods do
    def ltree_many(relation_name, opts = {})
      foreign_key = opts[:foreign_key] || :path
      primary_key = opts[:primary_key] || :path
      klass_name = opts[:class_name] || relation_name.to_s.classify

      define_method "all_descendant_#{relation_name}" do
        klass = klass_name.constantize
        klass.where(
          "#{klass.table_name}.#{foreign_key} <@ ?", send(primary_key)
        )
      end

      # Ensure ltree-related paths are updated when the pk ltree path changes
      after_update_commit do
        if previous_changes[primary_key]
          klass = klass_name.constantize

          # Update exact path matches first
          klass.where(
            "#{klass.table_name}.#{foreign_key} = ?", previous_changes[primary_key].first
          ).update_all(["#{foreign_key} = ?", send(primary_key)])

          # Update remaining sub paths
          klass.where(
            "#{klass.table_name}.#{foreign_key} <@ ?", previous_changes[primary_key].first
          ).update_all(
            [
              "#{foreign_key} = ? || subpath(#{foreign_key}, nlevel(?))",
              send(primary_key), previous_changes[primary_key].first
            ]
          )
        end
      end

      before_destroy do
        if opts[:dependent]
          relation = send("all_descendant_#{relation_name}")

          relation.destroy_all if opts[:dependent] == :destroy
          relation.delete_all if opts[:dependent] == :delete_all
          relation.update_all(["#{foreign_key} = ?", nil]) if opts[:dependent] == :nullify
        end
      end
    end
  end
end
