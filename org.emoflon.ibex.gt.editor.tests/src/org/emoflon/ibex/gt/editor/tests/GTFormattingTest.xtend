package org.emoflon.ibex.gt.editor.tests

import com.google.inject.Inject

import org.eclipse.xtext.serializer.ISerializer
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.emoflon.ibex.gt.editor.gT.EditorGTFile
import org.junit.runner.RunWith
import org.junit.Test
import org.eclipse.xtext.resource.SaveOptions

import static org.junit.Assert.*

/**
 * JUnit tests for formatting.
 */
@RunWith(XtextRunner)
@InjectWith(GTInjectorProvider)
class GTFormattingTest {
	@Inject
	protected ParseHelper<EditorGTFile> parseHelper

	@Inject extension ISerializer

	@Test
	def formatImports() {
		val expected = '''
			import "platform:/resource/A/model/A.ecore"
			import "platform:/resource/B/model/B.ecore"
			
			rule test {
				object: EObject
			}
		'''
		testFormatting(
			expected,
			'''
				
				import"platform:/resource/A/model/A.ecore"
				import"platform:/resource/B/model/B.ecore"
				
				rule test {
					object: EObject
				}
			'''
		)
	}

	@Test
	def formatImportsIfEmpty() {
		val expected = '''
			rule test {
				object: EObject
			}
		'''
		testFormatting(
			expected,
			'''
				rule test {
					object: EObject
				}
			'''
		)
	}

	@Test
	def formatRules() {
		val expected = '''
			import "http://www.eclipse.org/emf/2002/Ecore"
			
			rule test {
				object: EObject
			}
			
			abstract rule test2 {
				name: EAnnotation
			}
			
			rule test3
			refines test, test2 {
				object2: EObject
			}
		'''
		testFormatting(
			expected,
			'''
				import "http://www.eclipse.org/emf/2002/Ecore"rule 
				test{object: EObject}abstract 
				rule test2 {name: EAnnotation}
				rule test3  refines  test ,  test2 
				{object2: EObject}
			'''
		)
		testFormatting(
			expected,
			'''
				
				import "http://www.eclipse.org/emf/2002/Ecore"
					
				rule 	test 	{
				object	: EObject
				}
					
				abstract
				rule  test2{
					name   :   
					EAnnotation}
				rule test3  refines  
				test ,  test2 {object2: EObject}
			'''
		)
	}

	@Test
	def formatRuleWithEmptyBody() {
		val expected = '''
			import "http://www.eclipse.org/emf/2002/Ecore"
			
			rule test {
				object: EObject
			}
			
			abstract rule test2 {
				name: EAnnotation
			}
			
			rule test3
			refines test, test2
		'''
		testFormatting(
			expected,
			'''
				import "http://www.eclipse.org/emf/2002/Ecore"rule 
				test{object: EObject}abstract 
				rule test2 {name: EAnnotation}
				rule test3  refines  test ,  test2
			'''
		)
	}

	@Test
	def formatParameters() {
		val expected = '''
			import "http://www.eclipse.org/emf/2002/Ecore"
			
			rule test(a: EObject, b: EObject, c: EObject) {
				c: EObject
			}
		'''
		testFormatting(
			expected,
			'''
				import "http://www.eclipse.org/emf/2002/Ecore"
				rule test (	  a :  EObject ,  b :  EObject , c : EObject )
					{
				c: EObject
					}
			'''
		)
	}

	@Test
	def formatAttributes() {
		val expected = '''
			import "http://www.eclipse.org/emf/2002/Ecore"
			
			rule createClass(name: EString, isAbstract: EBoolean) {
				++ clazz: EClass {
					.name := param::name
					.^abstract := param::isAbstract
				}
			}
		'''
		testFormatting(
			expected,
			'''
				import "http://www.eclipse.org/emf/2002/Ecore"
							
				rule createClass(name: EString, isAbstract: EBoolean) {
				++ clazz: EClass {.name   :=   param::name .^abstract  :=  param::isAbstract}
				}
			'''
		)
	}

	@Test
	def formatReferences() {
		val expected = '''
			import "http://www.eclipse.org/emf/2002/Ecore"
			
			rule test {
				a: EAnnotation {
					-eAnnotations -> b
					-- -eAnnotations -> c
				}
			
				b: EAnnotation {
					++ -eAnnotations -> c
				}
			
				c: EAnnotation
			}
		'''
		testFormatting(
			expected,
			'''
				import "http://www.eclipse.org/emf/2002/Ecore"
				rule test {
				a: EAnnotation {   -   eAnnotations   ->    b	
				-- -eAnnotations  ->  c}	
				
				b: EAnnotation  
				{
				++- eAnnotations->c
				}
				c: EAnnotation
				}
			'''
		)
	}

	@Test
	def formatConditions() {
		val expected = '''
			import "http://www.eclipse.org/emf/2002/Ecore"
			
			pattern findClassWithoutAnnotation {
				clazz: EClass
			}
			when noAnnotation
			
			pattern findClass {
				clazz: EClass
			}
			when noAnnotation || hasAnnotation
			
			abstract pattern findClassWithAnnotation {
				clazz: EClass {
					-eAnnotations -> annotation
				}
			
				annotation: EAnnotation
			}
			
			condition noAnnotation = forbid findClassWithAnnotation
			
			condition hasAnnotation = enforce findClassifierWithAnnotation
			
			condition andTest = noAnnotation && hasAnnotation
		'''
		testFormatting(
			expected,
			'''
				import "http://www.eclipse.org/emf/2002/Ecore"	
					pattern findClassWithoutAnnotation {clazz: EClass}	when  noAnnotation  
								
				pattern findClass { clazz: EClass }	when 
						noAnnotation 
					|| 
						hasAnnotation
					
				abstract pattern findClassWithAnnotation {
				clazz: EClass {-eAnnotations -> annotation}
				annotation: EAnnotation}
					
				condition noAnnotation 
					= forbid  findClassWithAnnotation
				condition hasAnnotation  =  enforce  findClassifierWithAnnotation
				
					condition  andTest 
					=  noAnnotation    &&     hasAnnotation
			'''
		)
	}

	@Test
	def formatConditionsWithLongLines() {
		val expected = '''
			import "http://www.eclipse.org/emf/2002/Ecore"
			
			pattern p {
				object: EObject
			}
			when conditionOneWithAVeryLongName
			  || conditionTwoWithAVeryLongName
			  || conditionThreeWithAVeryLongName
			
			pattern theFirstPatternUsedInTheConditionsWithAVeryLongName {
				object: EObject
			}
			
			pattern theSecondPatternUsedInTheConditionsWithAVeryLongName {
				object: EObject
			}
			
			condition conditionOneWithAVeryLongName = forbid theFirstPatternUsedInTheConditionsWithAVeryLongName
			
			condition conditionTwoWithAVeryLongName = enforce theSecondPatternUsedInTheConditionsWithAVeryLongName
			
			condition conditionThreeWithAVeryLongName = conditionOneWithAVeryLongName
				&& conditionTwoWithAVeryLongName
		'''
		testFormatting(
			expected,
			'''
				import "http://www.eclipse.org/emf/2002/Ecore"
					
				pattern p {
					object: EObject
				} when  conditionOneWithAVeryLongName  || conditionTwoWithAVeryLongName || conditionThreeWithAVeryLongName
				
				pattern theFirstPatternUsedInTheConditionsWithAVeryLongName {
					object: EObject
				}
				
				pattern theSecondPatternUsedInTheConditionsWithAVeryLongName {
								object: EObject
							}
				
					condition
				conditionOneWithAVeryLongName 
					= 
					forbid 
					theFirstPatternUsedInTheConditionsWithAVeryLongName
				
				condition
					conditionTwoWithAVeryLongName 
					= 
					enforce theSecondPatternUsedInTheConditionsWithAVeryLongName
				
				condition   conditionThreeWithAVeryLongName 
					=    conditionOneWithAVeryLongName 
					&& 	 conditionTwoWithAVeryLongName
			'''
		)
	}

	def testFormatting(String expected, String code) {
		val actual = parseHelper.parse(code).serialize(SaveOptions.newBuilder.format.options)
		assertEquals(expected, actual)
	}
}
