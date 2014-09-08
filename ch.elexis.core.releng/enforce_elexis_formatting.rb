#!/usr/bin/env ruby
Profile = %(# inline. Look for #{__FILE__} inside https://raw.githubusercontent.com/elexis/elexis-3-core/master/3lexisFormatterProfile.xml
# Only syntax changed from XML to ini-file
org.eclipse.jdt.core.formatter.insert_space_after_ellipsis=insert
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_enum_declarations=insert
org.eclipse.jdt.core.formatter.insert_new_line_in_empty_annotation_declaration=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_allocation_expression=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_at_in_annotation_type_declaration=insert
org.eclipse.jdt.core.formatter.comment.new_lines_at_block_boundaries=true
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_constructor_declaration_parameters=insert
org.eclipse.jdt.core.formatter.comment.insert_new_line_for_parameter=insert
org.eclipse.jdt.core.formatter.insert_new_line_after_annotation_on_package=insert
org.eclipse.jdt.core.formatter.insert_space_between_empty_parens_in_enum_constant=do not insert
org.eclipse.jdt.core.formatter.blank_lines_after_imports=1
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_while=do not insert
org.eclipse.jdt.core.formatter.comment.insert_new_line_before_root_tags=insert
org.eclipse.jdt.core.formatter.insert_space_between_empty_parens_in_annotation_type_member_declaration=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_method_declaration_throws=do not insert
org.eclipse.jdt.core.formatter.comment.format_javadoc_comments=true
org.eclipse.jdt.core.formatter.indentation.size=4
org.eclipse.jdt.core.formatter.insert_space_after_postfix_operator=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_for_increments=insert
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_type_arguments=insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_for_inits=do not insert
org.eclipse.jdt.core.formatter.insert_new_line_in_empty_anonymous_type_declaration=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_semicolon_in_for=insert
org.eclipse.jdt.core.formatter.disabling_tag=@formatter:off
org.eclipse.jdt.core.formatter.continuation_indentation=2
org.eclipse.jdt.core.formatter.alignment_for_enum_constants=20
org.eclipse.jdt.core.formatter.blank_lines_before_imports=1
org.eclipse.jdt.core.formatter.blank_lines_after_package=1
org.eclipse.jdt.core.formatter.insert_space_after_binary_operator=insert
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_multiple_local_declarations=insert
org.eclipse.jdt.core.formatter.alignment_for_arguments_in_enum_constant=20
org.eclipse.jdt.core.formatter.insert_space_after_opening_angle_bracket_in_parameterized_type_reference=do not insert
org.eclipse.jdt.core.formatter.comment.indent_root_tags=true
org.eclipse.jdt.core.formatter.wrap_before_or_operator_multicatch=true
org.eclipse.jdt.core.formatter.enabling_tag=@formatter:on
org.eclipse.jdt.core.formatter.insert_space_after_closing_brace_in_block=insert
org.eclipse.jdt.core.formatter.insert_space_before_parenthesized_expression_in_return=insert
org.eclipse.jdt.core.formatter.alignment_for_throws_clause_in_method_declaration=20
org.eclipse.jdt.core.formatter.insert_new_line_after_annotation_on_parameter=insert
org.eclipse.jdt.core.formatter.keep_then_statement_on_same_line=false
org.eclipse.jdt.core.formatter.insert_new_line_after_annotation_on_field=insert
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_explicitconstructorcall_arguments=insert
org.eclipse.jdt.core.formatter.insert_new_line_in_empty_block=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_prefix_operator=do not insert
org.eclipse.jdt.core.formatter.blank_lines_between_type_declarations=1
org.eclipse.jdt.core.formatter.insert_space_before_closing_brace_in_array_initializer=insert
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_for=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_catch=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_angle_bracket_in_type_arguments=do not insert
org.eclipse.jdt.core.formatter.insert_new_line_after_annotation_on_method=insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_switch=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_anonymous_type_declaration=insert
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_parenthesized_expression=do not insert
org.eclipse.jdt.core.formatter.never_indent_line_comments_on_first_column=false
org.eclipse.jdt.core.compiler.problem.enumIdentifier=error
org.eclipse.jdt.core.formatter.insert_space_after_and_in_type_parameter=insert
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_for_inits=insert
org.eclipse.jdt.core.formatter.indent_statements_compare_to_block=true
org.eclipse.jdt.core.formatter.brace_position_for_anonymous_type_declaration=end_of_line
org.eclipse.jdt.core.formatter.insert_space_before_question_in_wildcard=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_annotation=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_method_invocation_arguments=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_switch=insert
org.eclipse.jdt.core.formatter.comment.line_length=100
org.eclipse.jdt.core.formatter.use_on_off_tags=true
org.eclipse.jdt.core.formatter.insert_space_between_empty_brackets_in_array_allocation_expression=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_enum_constant=insert
org.eclipse.jdt.core.formatter.insert_space_between_empty_parens_in_method_invocation=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_assignment_operator=insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_type_declaration=insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_for=do not insert
org.eclipse.jdt.core.formatter.comment.preserve_white_space_between_code_and_line_comments=false
org.eclipse.jdt.core.formatter.insert_new_line_after_annotation_on_local_variable=insert
org.eclipse.jdt.core.formatter.brace_position_for_method_declaration=end_of_line
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_method_invocation=do not insert
org.eclipse.jdt.core.formatter.alignment_for_union_type_in_multicatch=16
org.eclipse.jdt.core.formatter.insert_space_after_colon_in_for=insert
org.eclipse.jdt.core.formatter.number_of_blank_lines_at_beginning_of_method_body=0
org.eclipse.jdt.core.formatter.insert_space_after_closing_angle_bracket_in_type_arguments=insert
org.eclipse.jdt.core.formatter.keep_else_statement_on_same_line=false
org.eclipse.jdt.core.formatter.alignment_for_binary_expression=20
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_parameterized_type_reference=insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_array_initializer=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_multiple_field_declarations=insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_annotation=do not insert
org.eclipse.jdt.core.formatter.alignment_for_arguments_in_explicit_constructor_call=20
org.eclipse.jdt.core.formatter.indent_body_declarations_compare_to_annotation_declaration_header=true
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_superinterfaces=insert
org.eclipse.jdt.core.formatter.insert_space_before_colon_in_default=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_question_in_conditional=insert
org.eclipse.jdt.core.formatter.brace_position_for_block=end_of_line
org.eclipse.jdt.core.formatter.brace_position_for_constructor_declaration=end_of_line
org.eclipse.jdt.core.formatter.compact_else_if=true
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_type_parameters=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_catch=insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_method_invocation=do not insert
org.eclipse.jdt.core.formatter.put_empty_statement_on_new_line=true
org.eclipse.jdt.core.formatter.alignment_for_parameters_in_constructor_declaration=20
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_method_invocation_arguments=insert
org.eclipse.jdt.core.formatter.alignment_for_arguments_in_method_invocation=20
org.eclipse.jdt.core.formatter.alignment_for_throws_clause_in_constructor_declaration=20
org.eclipse.jdt.core.compiler.problem.assertIdentifier=error
org.eclipse.jdt.core.formatter.comment.clear_blank_lines_in_block_comment=false
org.eclipse.jdt.core.formatter.insert_new_line_before_catch_in_try_statement=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_try=insert
org.eclipse.jdt.core.formatter.insert_new_line_at_end_of_file_if_missing=do not insert
org.eclipse.jdt.core.formatter.comment.clear_blank_lines_in_javadoc_comment=false
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_array_initializer=insert
org.eclipse.jdt.core.formatter.insert_space_before_binary_operator=insert
org.eclipse.jdt.core.formatter.insert_space_before_unary_operator=do not insert
org.eclipse.jdt.core.formatter.alignment_for_expressions_in_array_initializer=20
org.eclipse.jdt.core.formatter.format_line_comment_starting_on_first_column=true
org.eclipse.jdt.core.formatter.number_of_empty_lines_to_preserve=1
org.eclipse.jdt.core.formatter.insert_space_after_colon_in_case=insert
org.eclipse.jdt.core.formatter.insert_space_before_ellipsis=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_semicolon_in_try_resources=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_colon_in_assert=insert
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_if=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_type_arguments=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_and_in_type_parameter=insert
org.eclipse.jdt.core.formatter.insert_new_line_in_empty_type_declaration=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_parenthesized_expression=do not insert
org.eclipse.jdt.core.formatter.comment.format_line_comments=false
org.eclipse.jdt.core.formatter.insert_space_after_colon_in_labeled_statement=insert
org.eclipse.jdt.core.formatter.align_type_members_on_columns=false
org.eclipse.jdt.core.formatter.alignment_for_assignment=20
org.eclipse.jdt.core.formatter.insert_new_line_in_empty_method_body=do not insert
org.eclipse.jdt.core.formatter.indent_body_declarations_compare_to_type_header=true
org.eclipse.jdt.core.formatter.insert_space_between_empty_parens_in_method_declaration=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_enum_constant=do not insert
org.eclipse.jdt.core.formatter.alignment_for_superinterfaces_in_type_declaration=16
org.eclipse.jdt.core.formatter.blank_lines_before_first_class_body_declaration=0
org.eclipse.jdt.core.formatter.alignment_for_conditional_expression=80
org.eclipse.jdt.core.formatter.insert_new_line_before_closing_brace_in_array_initializer=insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_constructor_declaration_parameters=do not insert
org.eclipse.jdt.core.formatter.format_guardian_clause_on_one_line=false
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_if=insert
org.eclipse.jdt.core.formatter.insert_new_line_after_annotation_on_type=insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_block=insert
org.eclipse.jdt.core.formatter.brace_position_for_enum_declaration=end_of_line
org.eclipse.jdt.core.formatter.brace_position_for_block_in_case=end_of_line
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_constructor_declaration=do not insert
org.eclipse.jdt.core.formatter.comment.format_header=false
org.eclipse.jdt.core.formatter.alignment_for_arguments_in_allocation_expression=20
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_method_invocation=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_while=insert
org.eclipse.jdt.core.compiler.codegen.inlineJsrBytecode=enabled
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_switch=do not insert
org.eclipse.jdt.core.formatter.alignment_for_method_declaration=0
org.eclipse.jdt.core.formatter.join_wrapped_lines=true
org.eclipse.jdt.core.formatter.insert_space_between_empty_parens_in_constructor_declaration=do not insert
org.eclipse.jdt.core.formatter.indent_switchstatements_compare_to_cases=true
org.eclipse.jdt.core.formatter.insert_space_before_closing_bracket_in_array_allocation_expression=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_synchronized=do not insert
org.eclipse.jdt.core.formatter.comment.new_lines_at_javadoc_boundaries=true
org.eclipse.jdt.core.formatter.brace_position_for_annotation_type_declaration=end_of_line
org.eclipse.jdt.core.formatter.insert_space_before_colon_in_for=insert
org.eclipse.jdt.core.formatter.alignment_for_resources_in_try=80
org.eclipse.jdt.core.formatter.use_tabs_only_for_leading_indentations=false
org.eclipse.jdt.core.formatter.alignment_for_selector_in_method_invocation=20
org.eclipse.jdt.core.formatter.never_indent_block_comments_on_first_column=false
org.eclipse.jdt.core.compiler.source=1.7
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_synchronized=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_constructor_declaration_throws=insert
org.eclipse.jdt.core.formatter.tabulation.size=4
org.eclipse.jdt.core.formatter.insert_new_line_in_empty_enum_constant=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_allocation_expression=insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_bracket_in_array_reference=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_colon_in_conditional=insert
org.eclipse.jdt.core.formatter.comment.format_source_code=true
org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_array_initializer=insert
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_try=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_semicolon_in_try_resources=insert
org.eclipse.jdt.core.formatter.blank_lines_before_field=0
org.eclipse.jdt.core.formatter.insert_space_after_at_in_annotation=do not insert
org.eclipse.jdt.core.formatter.continuation_indentation_for_array_initializer=2
org.eclipse.jdt.core.formatter.insert_space_after_question_in_wildcard=do not insert
org.eclipse.jdt.core.formatter.blank_lines_before_method=1
org.eclipse.jdt.core.formatter.alignment_for_superclass_in_type_declaration=16
org.eclipse.jdt.core.formatter.alignment_for_superinterfaces_in_enum_declaration=20
org.eclipse.jdt.core.formatter.insert_space_before_parenthesized_expression_in_throw=insert
org.eclipse.jdt.core.formatter.insert_space_before_colon_in_labeled_statement=do not insert
org.eclipse.jdt.core.compiler.codegen.targetPlatform=1.7
org.eclipse.jdt.core.formatter.brace_position_for_switch=end_of_line
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_superinterfaces=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_method_declaration_parameters=insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_brace_in_array_initializer=insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_parenthesized_expression=do not insert
org.eclipse.jdt.core.formatter.comment.format_html=true
org.eclipse.jdt.core.formatter.insert_space_after_at_in_annotation_type_declaration=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_closing_angle_bracket_in_type_parameters=insert
org.eclipse.jdt.core.formatter.alignment_for_compact_if=16
org.eclipse.jdt.core.formatter.indent_empty_lines=true
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_parameterized_type_reference=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_unary_operator=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_enum_constant=do not insert
org.eclipse.jdt.core.formatter.alignment_for_arguments_in_annotation=0
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_enum_declarations=do not insert
org.eclipse.jdt.core.formatter.keep_empty_array_initializer_on_one_line=false
org.eclipse.jdt.core.formatter.indent_switchstatements_compare_to_switch=false
org.eclipse.jdt.core.formatter.insert_new_line_before_else_in_if_statement=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_assignment_operator=insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_constructor_declaration=do not insert
org.eclipse.jdt.core.formatter.blank_lines_before_new_chunk=1
org.eclipse.jdt.core.formatter.insert_new_line_after_label=do not insert
org.eclipse.jdt.core.formatter.indent_body_declarations_compare_to_enum_declaration_header=true
org.eclipse.jdt.core.formatter.insert_space_after_opening_bracket_in_array_allocation_expression=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_constructor_declaration=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_colon_in_conditional=insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_angle_bracket_in_parameterized_type_reference=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_method_declaration_parameters=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_closing_angle_bracket_in_type_arguments=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_cast=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_colon_in_assert=insert
org.eclipse.jdt.core.formatter.blank_lines_before_member_type=1
org.eclipse.jdt.core.formatter.insert_new_line_before_while_in_do_statement=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_bracket_in_array_type_reference=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_closing_angle_bracket_in_parameterized_type_reference=do not insert
org.eclipse.jdt.core.formatter.alignment_for_arguments_in_qualified_allocation_expression=20
org.eclipse.jdt.core.formatter.insert_new_line_after_opening_brace_in_array_initializer=insert
org.eclipse.jdt.core.formatter.insert_new_line_in_empty_enum_declaration=do not insert
org.eclipse.jdt.core.formatter.indent_breaks_compare_to_cases=true
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_method_declaration=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_if=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_semicolon=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_postfix_operator=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_try=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_angle_bracket_in_type_arguments=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_cast=do not insert
org.eclipse.jdt.core.formatter.comment.format_block_comments=false
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_method_declaration=do not insert
org.eclipse.jdt.core.formatter.keep_imple_if_on_one_line=false
org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_enum_declaration=insert
org.eclipse.jdt.core.formatter.alignment_for_parameters_in_method_declaration=20
org.eclipse.jdt.core.formatter.insert_space_between_brackets_in_array_type_reference=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_angle_bracket_in_type_parameters=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_semicolon_in_for=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_method_declaration_throws=insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_bracket_in_array_allocation_expression=do not insert
org.eclipse.jdt.core.formatter.indent_statements_compare_to_body=true
org.eclipse.jdt.core.formatter.alignment_for_multiple_fields=16
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_enum_constant_arguments=insert
org.eclipse.jdt.core.formatter.insert_space_before_prefix_operator=do not insert
org.eclipse.jdt.core.formatter.brace_position_for_array_initializer=end_of_line
org.eclipse.jdt.core.formatter.wrap_before_binary_operator=true
org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_method_declaration=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_type_parameters=insert
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_catch=do not insert
org.eclipse.jdt.core.compiler.compliance=1.7
org.eclipse.jdt.core.formatter.insert_space_before_closing_bracket_in_array_reference=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_comma_in_annotation=insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_enum_constant_arguments=do not insert
org.eclipse.jdt.core.formatter.insert_space_between_empty_braces_in_array_initializer=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_colon_in_case=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_multiple_local_declarations=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_annotation_type_declaration=insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_bracket_in_array_reference=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_method_declaration=do not insert
org.eclipse.jdt.core.formatter.wrap_outer_expressions_when_nested=true
org.eclipse.jdt.core.formatter.insert_space_after_closing_paren_in_cast=insert
org.eclipse.jdt.core.formatter.brace_position_for_enum_constant=end_of_line
org.eclipse.jdt.core.formatter.brace_position_for_type_declaration=end_of_line
org.eclipse.jdt.core.formatter.blank_lines_before_package=0
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_for=insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_synchronized=insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_for_increments=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_annotation_type_member_declaration=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_while=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_enum_constant=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_explicitconstructorcall_arguments=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_closing_paren_in_annotation=do not insert
org.eclipse.jdt.core.formatter.insert_space_after_opening_angle_bracket_in_type_parameters=do not insert
org.eclipse.jdt.core.formatter.indent_body_declarations_compare_to_enum_constant_header=true
org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_constructor_declaration=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_constructor_declaration_throws=do not insert
org.eclipse.jdt.core.formatter.join_lines_in_comments=true
org.eclipse.jdt.core.formatter.insert_space_before_closing_angle_bracket_in_type_parameters=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_question_in_conditional=insert
org.eclipse.jdt.core.formatter.comment.indent_parameter_description=true
org.eclipse.jdt.core.formatter.insert_new_line_before_finally_in_try_statement=do not insert
org.eclipse.jdt.core.formatter.tabulation.char=tab
org.eclipse.jdt.core.formatter.insert_space_before_comma_in_multiple_field_declarations=do not insert
org.eclipse.jdt.core.formatter.blank_lines_between_import_groups=1
org.eclipse.jdt.core.formatter.lineSplit=100
org.eclipse.jdt.core.formatter.insert_space_after_opening_paren_in_annotation=do not insert
org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_switch=insert
)

# Copyright 2011 by Niklaus Giger <niklaus.giger@member.fsf.org>
#
# Based on http://www.peterfriese.de/formatting-your-code-using-the-eclipse-code-formatter/
# Can be compared to https://raw.githubusercontent.com/elexis/elexis-3-core/master/3lexisFormatterProfile.xml
# You should just see the differences based on the syntax (XML versus ini-file)
# and the code here and below which is a simple ruby script
#

# ECLIPSE=`which eclipse`.chomp
ECLIPSE='eclipse'
if ARGV.length != 1
  puts "Missing dir argument. "
  puts "   #{__FILE__} will enforce the ElexisFormatterProfile for all *.java files below"
  exit 2
end

DryRun = false

def system(cmd, mayFail=false)
  puts "cd #{Dir.pwd} && #{cmd} # mayFail #{mayFail}"
  if DryRun then return
  else res =Kernel.system(cmd)
  end
  if !res and !mayFail then
    puts "running #{cmd} #{mayFail} failed"
    exit 2
  end
end

puts "ARGV #{ARGV.inspect} in #{Dir.pwd}"
dir = ARGV.shift
Dir.chdir(dir)
tmpName = 'profile.tmp'
tmpProfile = File.open(tmpName, 'w+') { |f| f.puts Profile }
files = Dir.glob("*/src/**/*.java")

cmd="#{ECLIPSE} -application org.eclipse.jdt.core.JavaCodeFormatter -verbose " +
    "-config #{tmpName} #{files.join(' ')}"
system(cmd)
cmd="git commit -m 'JavaCodeFormatter enforced' #{files.join(' ')}"
system(cmd) # fails if nothing has changed, which is good as jenkins will not push a commit in this case