class TimeSlice
  SLICE_TYPES = {:day => 60 * 60 * 24, :quad => 60 * 60 * 4, :hour => 60 * 60}
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
    # Tree is
    #   { :name, :tstart, :tend, :duration, :calls => [] }
    tree = CallTree.new(method_name, actions).to_hash
    time_modulo = (24 * 60 * 60 * 1000)
    id = "#{app_id}-hour-#{(tree[:tstart] % time_modulo) * time_modulo}"

    # Slice level
    MongoRaw.eval('update_timings', self.collection_name, id, nil, tree[:duration])

    # Deploy level
    MongoRaw.eval('update_timings', self.collection_name, id, deploy_key, tree[:duration])
  end

  # This will look up the timeslices and return to you
  # All the hashes of data (for now!)
  def self.find_by_range(start_time, end_time)

  end
end
