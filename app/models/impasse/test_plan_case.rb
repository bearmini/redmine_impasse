module Impasse
  class TestPlanCase < ActiveRecord::Base
    unloadable
    set_table_name "impasse_test_plan_cases"

    belongs_to :test_plan
    belongs_to :test_case

    def self.delete_cascade!(test_plan_id, test_case_id)
      node = Node.find(test_case_id)

      sql = <<-END_OF_SQL
DELETE FROM impasse_test_plan_cases
WHERE test_plan_id=#{test_plan_id}
  AND test_case_id in (
    SELECT distinct parent.id
    FROM impasse_nodes AS parent
    LEFT JOIN impasse_nodes AS child
      ON INSTR(child.path, parent.path) > 0
    LEFT JOIN impasse_test_cases AS tc
      ON child.id = tc.id
    WHERE parent.path LIKE '#{node.path}%'
      AND parent.node_type_id=3
  )
      END_OF_SQL

      connection.update(sql)
    end
  end
end
