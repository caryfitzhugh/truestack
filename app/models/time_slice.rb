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
class TimeSlice
  module SliceManipulationMethods
    def add_exception_to_slice(deploy_key, id, exception_name, failed_in_method, actions, tstart, backtrace, env)

    end

    def add_browser_ready_timing_to_slice(deploy_key, id, request_method_name, tstart, duration)
      method_name = "browser#ready"
      MongoRaw.eval('update_timings_but_not_count', self.collection_name, id, "#{deploy_key}", duration)
      MongoRaw.eval('update_timings_but_not_count', self.collection_name, id, "#{deploy_key}.#{request_method_name}", duration)
      MongoRaw.eval('update_timings_but_not_count', self.collection_name, id, "#{deploy_key}.#{request_method_name}.#{method_name}", duration)
      MongoRaw.eval('update_timings', self.collection_name, id, "methods.#{method_name}", duration)
    end

    def add_request_to_slice(deploy_key, id, tree)
      # Top-deploy level
      MongoRaw.eval('update_timings', self.collection_name, id, deploy_key, tree.root[:duration])

      # Deploy level
      path = [deploy_key];
      tree.for_each do |node|
        # For each of the actions , traverse the tree and then call update_timings on them.
        MongoRaw.eval('update_timings', self.collection_name, id, ([deploy_key] + [node[:path]]).join('.'), node[:duration])

        # Do this just for the individual methods
        # This rolls them up so that we get an overall timing for each method in the slice
        # Method detail page!
        MongoRaw.eval('update_timings', self.collection_name, id,"methods.#{node[:name]}", node[:duration])
      end
    end

    def slice_id(start, app_id)
      # Convert to MS
      timestamp = (start / (self::SLICE_WINDOW * 1000)).to_i * 1000 * self::SLICE_WINDOW

      "#{app_id}-#{timestamp}"
    end
  end

  class Day
    SLICE_WINDOW = 60 * 60 * 24
    include Mongoid::Document
    extend SliceManipulationMethods
    belongs_to :user_application
  end

  class Hour
    SLICE_WINDOW = 60 * 60
    include Mongoid::Document
    extend SliceManipulationMethods
    belongs_to :user_application
  end

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

    [TimeSlice::Day, TimeSlice::Hour].each do |slice_klass|
      id = slice_klass.slice_id(tree.root[:tstart], app_id)

      slice_klass.add_request_to_slice(deploy_key, id, tree)
    end

  end

  def self.add_browser_ready_timing(app_id, deploy_key, request_method_name, tstart, duration)

    [TimeSlice::Day, TimeSlice::Hour].each do |slice_klass|

      id = slice_klass.slice_id(tstart, app_id)

      slice_klass.add_browser_ready_timing_to_slice(deploy_key, id, request_method_name, tstart, duration)
    end
  end

  def self.add_exception(app_id, deploy_key, exception_name, failed_in_method, actions, tstart, backtrace, env)
    # Look up the last timing for the given failed in method.
    # That is the 'instance' which has an exception
    # Add the request, with this extra data.

    [TimeSlice::Day, TimeSlice::Hour].each do |slice_klass|

      id = slice_klass.slice_id(tstart, app_id)

      slice_klass.add_exception_to_slice(deploy_key, id, tree)
    end
  end
end
