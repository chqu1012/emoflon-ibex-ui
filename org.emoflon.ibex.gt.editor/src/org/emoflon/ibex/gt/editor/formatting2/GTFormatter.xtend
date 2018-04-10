package org.emoflon.ibex.gt.editor.formatting2

import java.util.List

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument

import org.emoflon.ibex.gt.editor.gT.EditorAttribute
import org.emoflon.ibex.gt.editor.gT.EditorGTFile
import org.emoflon.ibex.gt.editor.gT.EditorImport
import org.emoflon.ibex.gt.editor.gT.EditorNode
import org.emoflon.ibex.gt.editor.gT.EditorOperator
import org.emoflon.ibex.gt.editor.gT.EditorParameter
import org.emoflon.ibex.gt.editor.gT.EditorPattern
import org.emoflon.ibex.gt.editor.gT.EditorReference
import org.emoflon.ibex.gt.editor.gT.GTPackage

/**
 * Formatting
 * 
 * https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#formatting
 */
class GTFormatter extends AbstractFormatter2 {

	def dispatch void format(EditorGTFile file, extension IFormattableDocument document) {
		// No space before first import.
		if (file.imports.size > 0) {
			file.imports.get(0).prepend[noSpace]
		}

		// Empty line after imports
		this.formatList(file.imports, document, 0, 1, 2)

		// Empty line between each pattern.
		this.formatList(file.patterns, document, if(file.imports.size > 0) 2 else 0, 2, 1)
	}

	def dispatch void format(EditorImport i, extension IFormattableDocument document) {
		i.regionFor.keyword("import").append[oneSpace]
	}

	def dispatch void format(EditorPattern pattern, extension IFormattableDocument document) {
		// One space between modifier and pattern keyword.
		if (pattern.abstract) {
			pattern.regionFor.keyword("abstract").append[oneSpace]
		}

		// One space between pattern keyword and name.
		pattern.regionFor.feature(GTPackage.Literals.EDITOR_PATTERN__TYPE).append[oneSpace]

		// New line before "refines", one space after "refines".
		pattern.regionFor.keyword("refines").prepend[newLine]
		pattern.regionFor.keyword("refines").append[oneSpace]

		// No space between pattern name, "(" and first parameter.
		pattern.regionFor.keyword("(").prepend[noSpace]
		pattern.regionFor.keyword("(").append[noSpace]

		pattern.parameters.forEach [
			it.format
		]

		pattern.regionFor.keywords(",").forEach [
			it.prepend[noSpace]
			it.append[oneSpace]
		]

		// No space between last parameter and ")", but one space between ")" and "{"
		pattern.regionFor.keyword(")").prepend[noSpace]
		pattern.regionFor.keyword(")").append[oneSpace]

		// One space before "{".
		pattern.regionFor.keyword("{").prepend[oneSpace]

		// Indent everything between "{" and "}".
		val body = pattern.regionFor.keywordPairs("{", "}")
		if (body.size > 0) {
			body.get(0).interior[indent]
		}

		// Empty line between nodes.
		this.formatList(pattern.nodes, document, 1, 2, 1)
	}

	def dispatch void format(EditorParameter parameter, extension IFormattableDocument document) {
		// No space before ":", one space after ":".
		parameter.regionFor.keyword(":").prepend[noSpace]
		parameter.regionFor.keyword(":").append[oneSpace]
	}

	def dispatch void format(EditorNode node, extension IFormattableDocument document) {
		// One space before "{".
		node.regionFor.keyword("{").prepend[oneSpace]

		// No space before ":", but one space after ":".
		node.regionFor.keyword(":").prepend[noSpace]
		node.regionFor.keyword(":").append[oneSpace]

		// Indent everything between "{" and "}".
		val nodeContent = node.regionFor.keywordPairs("{", "}")
		if (nodeContent.size > 0) {
			nodeContent.get(0).interior[indent]
		}

		// New line for each attribute.
		node.attributes.forEach [
			it.format
			it.surround[newLine]
		]

		// New line for each reference.
		node.references.forEach [
			it.format
			it.surround[newLine]
		]
	}

	def dispatch void format(EditorAttribute attribute, extension IFormattableDocument document) {
		// No space before and after ".".
		attribute.regionFor.keyword(".").surround[noSpace]

		// One space before and after the relation.
		attribute.regionFor.feature(GTPackage.Literals.EDITOR_ATTRIBUTE__RELATION).surround[oneSpace]
	}

	def dispatch void format(EditorReference reference, extension IFormattableDocument document) {
		if (reference.operator == EditorOperator.CONTEXT) {
			// No space before "-" and between "-" and the reference name.
			reference.regionFor.keyword("-").surround[noSpace]
		} else {
			// One space between operator and "-".
			reference.regionFor.feature(GTPackage.Literals.EDITOR_REFERENCE__OPERATOR).append[oneSpace]

			// One space before "-", but no space between "-" and the reference name.
			reference.regionFor.keyword("-").prepend[oneSpace]
			reference.regionFor.keyword("-").append[noSpace]
		}

		// One space before and after ->.
		reference.regionFor.keyword("->").surround[oneSpace]
	}

	/**
	 * Formats a list.
	 */
	def void formatList(List<? extends EObject> items, extension IFormattableDocument document, int newLinesBeforeFirst,
		int newLinesAfterItem, int newLinesAfterLastItem) {
		if (items.size() == 0) {
			return;
		}

		if (newLinesBeforeFirst > 0) {
			items.get(0).prepend[newLines = newLinesBeforeFirst]
		}

		for (var index = 0; index < items.size() - 1; index++) {
			items.get(index).format
			items.get(index).append[newLines = newLinesAfterItem]
		}

		items.get(items.size() - 1).format
		items.get(items.size() - 1).append[newLines = newLinesAfterLastItem]
	}
}