class TimeSlice
  SLICE_TYPES = {:day  => 60 * 60 * 24,
                 :quad => 60 * 60 * 4,
                 :hour => 60 * 60}
  include Mongoid::Document

  # @CMS = Count. Mean. StdDev
  # @PRT = Percent of request time (per type)
  # Our document looks like:
  # _ID = #{APP_ID}_#{SLICE_ID}_#{TIMESTAMP}
  # { ** timings_stuff
  #   deploys => {
  #     deploy_hash => {
  #       @CMS - all_requests
  #       @PRT - all_requests
  #       requests: {
  #         method#name : {
  #           @CMS - this request
  #           @PRT - this request
  #           exceptions: [exception_name:backtrace_[0]_line]
  #           methods: {
  #             called_method#name => { .. recursive .. w/o the PRT }
  #             called_method#name2 => { .. }
  #           }
  #         }
  #       },
  #       methods: {
  #         klass#action => {
  #           @CMS - this_method
  #           type:  the type (browser, etc. etc)
  #           requests: {
  #             cont#action1 => { @CMS - this_method in this request }
  #             cont#action2 => { @CMS - this_method in this request }
  #             cont#action3 => { @CMS - this_method in this request }
  #           }
  #         }
  #       },
  #       exceptions: {
  #         name#line_no => [timestamp]
  #       }
  #     }
  #     other_deploy_hash => {
  #     },
  #   },
  #
  #
  #
  def self.add_request(app_id, deploy_key, method_name, actions)
    # Convert array of methods to tree, start with the root!
    # Actions are:
    #   {
    #     method#name => [
    #       { tstart: , tend:}
    #     ]
    #   }
    #
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
    pp "SLICE -- #{id}"
    # Slice level
    MongoRaw.eval('update_timings', self.collection_name, id, nil, tree.root[:duration])

    # Deploy level
    path = [deploy_key];
    tree.for_each do |node|
      # For each of the actions , traverse the tree and then call update_timings on them.
      # DO THE TOP_LEVEL METHOD TYPE AGGREGATION

      MongoRaw.eval('update_timings', self.collection_name, id, ([deploy_key] + [node[:path]]).join('.'), node[:duration])
    end
  end

  # This will look up the timeslices and return to you
  # All the hashes of data (for now!)
  def self.find_by_range(start_time, end_time)

  end
end
