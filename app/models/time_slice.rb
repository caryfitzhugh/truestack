class TimeSlice
  SLICE_TYPES = {:day  => 60 * 60 * 24,
                 :quad => 60 * 60 * 4,
                 :hour => 60 * 60}
  include Mongoid::Document

  # @CMS = Count. Mean. StdDev
  # Our document looks like:
  # _ID = #{APP_ID}_#{SLICE_ID}_#{TIMESTAMP}
  # { ** timings_stuff
  #   deploys => {
  #     deploy_hash => {
  #       @CMS - all_requests
  #       requests: {
  #         method#name : {
  #           @CMS - this request
  #           exceptions: [exception_name:backtrace_[0]_line]
  #           methods: {
  #             called_method#name => { .. recursive .. }
  #             called_method#name2 => { .. }
  #           }
  #         }
  #       },
  #       methods: {
  #         klass#action => {
  #           @CMS - this_method
  #         }
  #       },
  #       exceptions: {
  #         name#line_no => [timestamp]
  #       }
  #     }
  #     other_deploy_hash => {
  #     },
  #   },
  def self.add_request(app_id, deploy_key, method_name, actions)
    # Convert array of methods to tree, start with the root!
    # Actions are:
    #   {
    #     method#name => [
    #       { tstart: , tend:}
    #     ]
    #   }

    # Tree is
    #   { :name, :tstart, :tend, :duration, :calls => [] }
    tree = CallTree.new(method_name, actions)

    SLICE_TYPES.each_pair do |slice_name, slice_mod|
      add_request_to_slice(deploy_key, slice_name, slice_mod, app_id, tree)
    end
  end

  def self.add_request_to_slice(deploy_key, slice_name, time_modulo, app_id, tree)
    # Convert to MS
    timestamp = (tree.root[:tstart] / (time_modulo * 1000)).to_i * 1000 * time_modulo

    id = "#{app_id}-#{slice_name}-#{timestamp}"

    # Top-deploy level
    MongoRaw.eval('update_timings', self.collection_name, id, deploy_key, tree.root[:duration])

    # Deploy level
    path = [deploy_key];
    tree.for_each do |node|
      # DO THE TOP_LEVEL METHOD TYPE AGGREGATION

      # For each of the actions , traverse the tree and then call update_timings on them.
      MongoRaw.eval('update_timings', self.collection_name, id, ([deploy_key] + [node[:path]]).join('.'), node[:duration])

      # Do this just for the individual methods
      # This rolls them up so that we get an overall timing for each method in the slice
      # Method detail page!
      MongoRaw.eval('update_timings', self.collection_name, id,"methods.#{node[:name]}", node[:duration])
    end
  end

  def self.add_browser_ready_timing(app_id, deploy_key, request_method_name, tstart, duration)
    SLICE_TYPES.each_pair do |slice_name, slice_mod|
      # Convert to MS
      timestamp = (tstart / (slice_mod * 1000)).to_i * 1000 * slice_mod

      id = "#{app_id}-#{slice_name}-#{timestamp}"

      method_name = "browser#ready"
      MongoRaw.eval('update_timings_but_not_count', self.collection_name, id, "#{deploy_key}", duration)
      MongoRaw.eval('update_timings_but_not_count', self.collection_name, id, "#{deploy_key}.#{request_method_name}", duration)
      MongoRaw.eval('update_timings_but_not_count', self.collection_name, id, "#{deploy_key}.#{request_method_name}.browser#ready", duration)

      MongoRaw.eval('update_timings', self.collection_name, id, "methods.#{method_name}", duration)
    end
  end

  def self.add_exception(app_id, deploy_key, exception_name, tstart, backtrace, env)

  end
end
