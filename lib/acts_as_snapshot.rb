module ActsAsSnapshot

  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      named_scope :find_for_date_range, lambda {|start_date, end_date| {:conditions => ['created_at >= ? AND created_at <= ?', start_date, (Time.zone.parse(end_date).utc + 1.day)] } }
    end
  end
    
  module ClassMethods

    def acts_as_snapshot
    end
    
    def for_date_range(start_date, end_date)
      _snapshots = self.find_for_date_range(start_date.strftime("%Y-%m-%d"), end_date.strftime("%Y-%m-%d"))
      _snapshots = [self.null_object] if _snapshots.blank?
      _snapshots
    end
    
    def null_snapshot(method_name)
      @null_snapshot_method = method_name
    end
    
    def null_object(args = {})
      self.send(@null_snapshot_method, args)
    end
    
    def acts_as_snapshot?
      true
    end

  end
  
end
