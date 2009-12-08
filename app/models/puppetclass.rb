class Puppetclass < ActiveRecord::Base
  has_and_belongs_to_many :environments
  has_and_belongs_to_many :operatingsystems
  has_and_belongs_to_many :hosts
  has_and_belongs_to_many :hostgroups

  validates_uniqueness_of :name
  validates_presence_of :name
  validates_associated :environments

  # scans for puppet classes
  # parameter is the module path
  # returns an array of puppetclasses objects
  def self.scanForClasses(path)
    klasses=Array.new
    Dir.glob("#{path}/*/manifests/**/*.pp").each do |manifest|
      File.read(manifest).each_line do |line|
        klass=line.match(/^class (\S+).*\{/)
         klasses << Puppetclass.find_or_create_by_name(klass[1]) if klass
      end
    end
    return klasses
  end

  def to_label
    name
  end
end
