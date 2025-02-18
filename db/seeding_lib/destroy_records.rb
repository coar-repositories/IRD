def destroy_records
  System.destroy_all
  Organisation.destroy_all
  Country.destroy_all
  Generator.destroy_all
  Platform.destroy_all
  Annotation.destroy_all
  Medium.destroy_all
  User.destroy_all
  Role.destroy_all
end