/*
 * generated by Xtext 2.14.0
 */
package org.emoflon.ibex.tgg.weights.validation

import com.google.inject.Inject
import language.TGG
import language.TGGRule
import language.TGGRuleCorr
import language.TGGRuleNode
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ContentHandler
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.common.types.JvmTypeReference
import org.eclipse.xtext.common.types.JvmUnknownTypeReference
import org.eclipse.xtext.common.types.util.TypeReferences
import org.eclipse.xtext.validation.Check
import org.emoflon.ibex.tgg.operational.matches.IMatch
import org.emoflon.ibex.tgg.weights.weightDefinition.DefaultCalculation
import org.emoflon.ibex.tgg.weights.weightDefinition.HelperFuncParameter
import org.emoflon.ibex.tgg.weights.weightDefinition.HelperFunction
import org.emoflon.ibex.tgg.weights.weightDefinition.Import
import org.emoflon.ibex.tgg.weights.weightDefinition.RuleWeightDefinition
import org.emoflon.ibex.tgg.weights.weightDefinition.WeightDefinitionFile
import org.emoflon.ibex.tgg.weights.weightDefinition.WeightDefinitionPackage
import org.emoflon.ibex.tgg.weights.weightDefinition.VariableDeclaration

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class WeightDefinitionValidator extends AbstractWeightDefinitionValidator {
	
	@Inject TypeReferences ref;
	
	/**
	 * Cached imported resource
	 */
	var Resource importedTGG

	/**
	 * Checks that there is at most one weight calculation per TGG rule
	 */
	@Check(FAST)
	def checkRuleUniqueness(RuleWeightDefinition ruleWeightDefinition) {
		(ruleWeightDefinition.eContainer as WeightDefinitionFile).weigthDefinitions.map[(it as RuleWeightDefinition)].
			filter[it !== ruleWeightDefinition].filter[it.rule === ruleWeightDefinition.rule].forEach [
				error(
					"Duplicated rule: " + (it.rule.name),
					ruleWeightDefinition,
					WeightDefinitionPackage.Literals.RULE_WEIGHT_DEFINITION__RULE
				)
			]
	}
	
	/**
	 * Checks there is at most one default calculation
	 */
	@Check(FAST)
	def checkOnlyOneDefaultMethod(DefaultCalculation defaultCalc) {
		if((defaultCalc.eContainer as WeightDefinitionFile).defaultCalc.length > 1) {
			error(
				"Duplicated \"default\": Only one default calculation is allowed",
				defaultCalc,
				WeightDefinitionPackage.Literals.DEFAULT_CALCULATION__CALC
			)
		} 
	}

	/**
	 * Checks whether the types of rule nodes can be resolved
	 */
	@Check(NORMAL)
	def checkNodeImports(RuleWeightDefinition ruleWeightDefinition) {
		for (node : ruleWeightDefinition.rule.nodes.filter[!(it instanceof TGGRuleCorr)]) {
			if (node.getTypeRef(ruleWeightDefinition) === null) {
				warning(
					'''Could not resolve type "«node.type.EPackage.name + "." + node.type.name»" of node "«node.name»"''',
					ruleWeightDefinition,
					WeightDefinitionPackage.Literals.RULE_WEIGHT_DEFINITION__RULE
				)
			}
		}
	}
	
	/**
	 * Resolves type references for the node's type. Returns null if no type is found
	 */
	private def JvmTypeReference getTypeRef(TGGRuleNode node, EObject context) {
		val typename = node.type.name
		val packageName = node.type.EPackage.name
		var JvmTypeReference ref = null
		try {
			ref = this.ref.getTypeForName(packageName + "." + typename, context)
		} catch (Exception e) {
			return null
		}
		if (ref === null || ref instanceof JvmUnknownTypeReference) {
			return null
		}
		return ref
	}
	
	/**
	 * Checks whether all variable names are unique
	 */
	@Check(FAST)
	def checkVariableUniqueness(VariableDeclaration variable) {
		(variable.eContainer as WeightDefinitionFile).variables.map[(it as VariableDeclaration)]
		.filter[it !== variable].filter[it.name == variable.name].forEach [
				error(
					"Duplicated variable declaration " + (variable.name),
					variable,
					WeightDefinitionPackage.Literals.VARIABLE_DECLARATION__NAME
				)
			]
	}

	/**
	 * Checks whether the imported file exists and contains a TGG
	 */
	@Check(NORMAL)
	def checkTggFile(Import importFile) {
		try {
			val uri = URI.createURI(importFile.importURI);
			val resolvedUri = uri.resolve(URI.createPlatformResourceURI("/", true))
			if ((importedTGG === null) || (importedTGG.URI != resolvedUri)) {
				importedTGG = new ResourceSetImpl().createResource(resolvedUri, ContentHandler.UNSPECIFIED_CONTENT_TYPE);
				importedTGG.load(null);
				EcoreUtil.resolveAll(importedTGG);
			}
		} catch (Exception e) {
			error(
				"Cannot load TGG from " + (importFile.importURI),
				importFile,
				WeightDefinitionPackage.Literals.IMPORT__IMPORT_URI
			)
			return
		}

		if (!importedTGG.contents.exists[it instanceof TGG]) {
			error(
				"File at \"" + (importFile.importURI) + "\" does not contain a TGG",
				importFile,
				WeightDefinitionPackage.Literals.IMPORT__IMPORT_URI
			)
		}
		if (!importedTGG.contents.filter[it instanceof TGG].flatMap[(it as TGG).rules].exists[it instanceof TGGRule]) {
			error(
				"File at \"" + (importFile.importURI) + "\" does not contain any TGG rules",
				importFile,
				WeightDefinitionPackage.Literals.IMPORT__IMPORT_URI
			)
		}
	}
	
	/**
	 * Checks helper functions are not duplicated
	 */
	@Check(NORMAL)
	def checkHelperFunctionNameUniqueness(HelperFunction helperFuntion) {
		(helperFuntion.eContainer as WeightDefinitionFile).helperFuntions.map[(it as HelperFunction)].
			filter[it !== helperFuntion]
			.filter[it.name == helperFuntion.name]
			.filter[helperFuntion.checkAllParametersEqual(it)]
			.forEach[
				error(
					"Duplicated function signature: " + (it.name),
					helperFuntion,
					WeightDefinitionPackage.Literals.HELPER_FUNCTION__NAME
				)
			]
	}
	
	/**
	 * Checks helper functions have unique variable names
	 */
	@Check(FAST)
	def checkFunctionParameterUniqueness(HelperFuncParameter parameter) {
		(parameter.eContainer as HelperFunction).params.map[(it as HelperFuncParameter)].
			filter[it !== parameter].filter[it.name == parameter.name].forEach [
				error(
					"Duplicated variable name: " + (it.name),
					parameter,
					WeightDefinitionPackage.Literals.HELPER_FUNC_PARAMETER__NAME
				)
			]
	}
	
	/**
	 * Checks whether all parameter types of the helperFunction are equal 
	 */
	private def checkAllParametersEqual(HelperFunction a, HelperFunction b) {
		if(a.params.size !== b.params.size)
			return false
		for(var i=0; i< a.params.size; i++) {
			if(a.params.get(i).parameterType.type != b.params.get(i).parameterType.type) {
					return false
				}
		}
		return true
	}
	
	/**
	 * Checks signature of helper function is not the signature of reserved functions
	 */
	@Check(FAST)
	def checkHelperMethodDoesNotHaveForbiddenName(HelperFunction h) {
		if(h.name == "calculateDefaultWeight" || 
			h.name == "calculateWeight"
		) {
			if(checkForGenericParameters(h)) {
				error(
					"Reserved function signature",
					h,
					WeightDefinitionPackage.Literals.HELPER_FUNCTION__NAME
				)
			}
		}
	}
	
	/**
	 * Check for signature of generic weight methods
	 */
	@Check(FAST)
	def checkForGenericParameters(HelperFunction h) {
		if(h.params.size == 2
			&& h.params.get(0).parameterType.type == ref.getTypeForName(String, h).type
			&& h.params.get(1).parameterType.type == ref.getTypeForName(IMatch, h).type
		) {
			return true;
		}
		return false;
	}
	
	/**
	 * Checks the helper function does not have the same signature as any rule weight function
	 */
	@Check(NORMAL)
	def checkHelperFunctionDoesNotMatchRuleWeightDef(HelperFunction h) {
		(h.eContainer as WeightDefinitionFile).weigthDefinitions.map[(it as RuleWeightDefinition)]
			.filter[checkHelperFunctionRuleWeightCombination(h, it)].forEach [
				error(
					'''Function signature duplicates weight calculation for rule "«it.rule.name»"''',
					h,
					WeightDefinitionPackage.Literals.HELPER_FUNCTION__NAME
				)
			]
	}
	
	/**
	 * Checks whether the helper function and the generated parameterized rule weight function have the same signature
	 */
	private def checkHelperFunctionRuleWeightCombination(HelperFunction h, RuleWeightDefinition ruleWeightDefinition) {
		val String ruleNameCalcMethod = '''calculateWeightFor«ruleWeightDefinition.rule.name»''' 
		if(h.name != ruleNameCalcMethod)
			return false
		val nodes = ruleWeightDefinition.rule.nodes.filter[!(it instanceof TGGRuleCorr)]
		if(h.params.size != nodes.size)
			return false
		for(var i=0; i< h.params.size; i++) {
			if(h.params.get(i).parameterType.type != nodes.get(i).getTypeRef(ruleWeightDefinition).type) {
				return false
			}
		}
		return true
	}
}
