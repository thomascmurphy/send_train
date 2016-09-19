# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

exercise_metric_types = ExerciseMetricType.create([
                                                    { label: 'Weight', input_field: 'number', slug: 'weight' },
                                                    { label: 'Repetitions', input_field: 'number', slug: 'repetitions' },
                                                    { label: 'Time', input_field: 'number', slug: 'time' },
                                                    { label: 'Campus Rungs', input_field: 'text', slug: 'campus-rungs' },
                                                    { label: 'Hold Type', input_field: 'select', slug: 'hold-type' },
                                                    { label: 'Boulder Grade', input_field: 'select', slug: 'boulder-grade' },
                                                    { label: 'Sport Grade', input_field: 'select', slug: 'sport-grade' },
                                                    { label: 'Rest Time', input_field: 'number', slug: 'rest-time' },
                                                    { label: 'Completion', input_field: 'range', slug: 'completion' },
                                                    { label: 'Hold Size', input_field: 'number', slug: 'hold-size' },
                                                  ])
