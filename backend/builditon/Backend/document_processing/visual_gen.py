def generate_mermaid_prompt(topic: str, context_data: str) -> str:
    """Template for Flowcharts."""
    return f"""
    Generate ONLY valid Mermaid.js graph TD code for: {topic}.
    Context: {context_data}
    Rule: No markdown backticks, no text explanations. Just start with 'graph TD'.
    """

def generate_mindmap_prompt(topic: str, context_data: str) -> str:
    """Template for Mindmaps."""
    return f"""
    Generate ONLY valid Mermaid.js mindmap code for: {topic}.
    Context: {context_data}
    Rule: No markdown, no text. Just start with 'mindmap'.
    """