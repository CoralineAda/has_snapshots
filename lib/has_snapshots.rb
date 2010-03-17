module HasSnapshots

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods

    def has_snapshots(model)
      include HasSnapshots::Behaviour
      @snapshot_model = model.to_s.pluralize
    end

    def has_snapshots?
      true
    end
    
    def snapshot_model
      @snapshot_model
    end
   
  end
  
  module Behaviour
  
    # Usage:
    #
    #   foo.snapshot(:last)
    #   foo.snapshot(:last => 10)
    #   foo.snapshot(:previous)
    #   foo.snapshot(:from => '2009-01-01', :to = '2009-12-31')
    #
    def snapshots(args=nil)
      
      # FIXME should return a nil object here
      return if snapshot_accessor.blank?
  
      # Handle :previous
      if args.is_a?(Symbol) && args == :previous
        return snapshot_accessor[-2] || null_snapshot
      end
      
      # Handle :last => x
      if args.is_a?(Hash) && args[:last]
        return (snapshot_accessor.slice(snapshot_accessor.size - args[:last], args[:last])) || [null_snapshot]
      end
      
      # Handle :from = x, :to => y
      if args.is_a?(Hash) && args[:from] && args[:to]
        return snapshot_accessor.for_date_range(args[:from], args[:to]) || [null_snapshot]
      end
      
      # Handle :last and default
      if args.blank? || (args.is_a?(Symbol) && args == :last)
        return snapshot_accessor[-1] || null_snapshot
      end
      
    end
  
    def previous_snapshot
      snapshots(:previous)
    end
    
    def current_snapshot
      snapshots(:last)
    end
    
    private
    
    def null_snapshot
      _model = eval(self.class.snapshot_model.singularize.camelize)
      _model.null_object("#{self.class.name.underscore}" => self)
    end
    
    def snapshot_accessor
      return @snapshot_accessor unless @snapshot_accessor.blank?
      _snapshot = self.send(self.class.snapshot_model)
      return @snapshot = _snapshot unless _snapshot.blank?
      return @snapshot = null_snapshot
    end
    
  end
  
end
