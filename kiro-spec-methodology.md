# Kiro Spec Development Methodology

This document contains the systematic approach for transforming feature ideas into actionable implementation plans using the spec-driven development methodology.

## Overview

The spec workflow follows three sequential phases:
1. **Requirements Gathering** - Transform ideas into structured user stories with acceptance criteria
2. **Design Document** - Create technical architecture and implementation approach
3. **Task List** - Break down design into discrete, actionable coding tasks

## Phase 1: Requirements Gathering

### Prompt Template for Requirements

```
Based on the feature idea: [FEATURE_DESCRIPTION]

Create a requirements document with:

1. **Introduction**: Clear summary of what this feature accomplishes and why it's valuable

2. **Requirements Structure**: Use hierarchical numbered requirements where each contains:
   - **User Story**: "As a [role], I want [feature], so that [benefit]"
   - **Acceptance Criteria**: Use EARS format (Easy Approach to Requirements Syntax)

### EARS Format Examples:
- WHEN [event] THEN [system] SHALL [response]
- IF [precondition] THEN [system] SHALL [response]
- WHILE [condition] THEN [system] SHALL [response]
- WHERE [location/context] THEN [system] SHALL [response]

### Key Considerations:
- Edge cases and error scenarios
- User experience and usability
- Technical constraints and limitations
- Success criteria and validation
- Security and privacy requirements
- Performance expectations
- Integration points with existing systems
```

### Requirements Quality Checklist:
- [ ] Each requirement has a clear user story
- [ ] Acceptance criteria are testable and measurable
- [ ] Edge cases are covered
- [ ] Error handling is specified
- [ ] Success criteria are defined
- [ ] Requirements are atomic (one concept per requirement)
- [ ] Dependencies between requirements are clear

## Phase 2: Design Document

### Prompt Template for Design

```
Based on the approved requirements document, create a comprehensive design that addresses:

## Research Areas to Investigate:
- Existing patterns and libraries for similar functionality
- Technical constraints and platform limitations
- Integration requirements with current architecture
- Performance and scalability considerations
- Security implications and best practices

## Design Document Structure:

### 1. Overview
- High-level approach and key design decisions
- How this design fulfills the requirements
- Major assumptions and constraints

### 2. Architecture
- System components and their relationships
- Data flow and interaction patterns
- Integration points with existing systems
- Deployment and runtime considerations

### 3. Components and Interfaces
- Detailed component breakdown
- Public APIs and interfaces
- Internal communication protocols
- External service integrations

### 4. Data Models
- Core data structures and their relationships
- Data validation and constraints
- Storage and persistence strategy
- Data migration considerations (if applicable)

### 5. Error Handling
- Error scenarios and recovery strategies
- User-facing error messages
- Logging and monitoring approach
- Fallback mechanisms

### 6. Testing Strategy
- Unit testing approach
- Integration testing requirements
- End-to-end testing scenarios
- Performance testing considerations

### Design Decision Framework:
For each major decision, document:
- **Options Considered**: What alternatives were evaluated
- **Decision Made**: What was chosen and why
- **Trade-offs**: What was gained/lost with this choice
- **Assumptions**: What assumptions does this decision rely on
```

### Design Quality Checklist:
- [ ] All requirements are addressed in the design
- [ ] Architecture is scalable and maintainable
- [ ] Error handling is comprehensive
- [ ] Testing strategy covers all critical paths
- [ ] Integration points are well-defined
- [ ] Performance considerations are addressed
- [ ] Security implications are considered

## Phase 3: Task List Creation

### Prompt Template for Tasks

```
Convert the approved design into a series of discrete coding tasks following these principles:

## Task Creation Guidelines:

### 1. Incremental Development
- Each task builds on previous tasks
- No big jumps in complexity
- Early validation of core functionality
- Test-driven development approach

### 2. Task Scope Rules
- ONLY include tasks involving writing, modifying, or testing code
- Each task should be completable in a focused work session
- Tasks should have clear, measurable completion criteria
- Avoid tasks requiring external dependencies or user testing

### 3. Task Format
Use numbered checkbox format with maximum two levels:
- [ ] 1. Top-level task description
  - Specific implementation details
  - Files/components to create or modify
  - Requirements references: _Requirements: X.X, Y.Y_

- [ ] 1.1 Sub-task if needed
  - More granular implementation steps
  - Specific code components to implement
  - Requirements references: _Requirements: X.X_

### 4. Task Categories to Include:
- Setup and project structure
- Data model implementation
- Core business logic
- API/interface implementation
- Error handling and validation
- Testing (unit, integration, e2e)
- Integration and wiring

### 5. Task Categories to EXCLUDE:
- User acceptance testing
- Deployment to production
- Performance metrics gathering
- User training or documentation
- Business process changes
- Marketing activities
- Manual testing requiring user interaction

### 6. Task Sequencing Strategy:
1. **Foundation**: Project structure, interfaces, data models
2. **Core Logic**: Business rules and algorithms
3. **Integration**: APIs, services, external connections
4. **Validation**: Error handling, edge cases
5. **Testing**: Comprehensive test coverage
6. **Wiring**: Connect all components together

### 7. Requirements Traceability:
- Each task must reference specific requirements
- Use granular requirement references (1.1, 2.3) not just user stories
- Ensure all requirements are covered by tasks
- Group related requirements in logical task sequences
```

### Task Quality Checklist:
- [ ] All requirements are covered by tasks
- [ ] Tasks are sequenced logically
- [ ] Each task is actionable by a coding agent
- [ ] No tasks require external dependencies
- [ ] Test coverage is comprehensive
- [ ] Integration tasks connect all components
- [ ] Tasks build incrementally in complexity

## Best Practices

### Requirements Phase:
- Start with user value and work backwards to technical needs
- Use concrete examples in acceptance criteria
- Consider both happy path and error scenarios
- Validate requirements against user workflows

### Design Phase:
- Research existing solutions and patterns first
- Design for testability and maintainability
- Consider future extensibility needs
- Document architectural decisions and trade-offs

### Task Phase:
- Prioritize early validation of core assumptions
- Ensure each task has clear completion criteria
- Plan for comprehensive testing throughout
- Sequence tasks to minimize rework

## Common Pitfalls to Avoid

### Requirements:
- Vague or untestable acceptance criteria
- Missing error scenarios
- Requirements that are too broad or too narrow
- Forgetting non-functional requirements

### Design:
- Over-engineering for future needs
- Insufficient error handling planning
- Ignoring existing system constraints
- Poor separation of concerns

### Tasks:
- Tasks that are too large or complex
- Missing integration between components
- Insufficient test coverage planning
- Tasks requiring manual validation

## Example Workflow Application

### Feature Idea: "User Authentication System"

**Requirements Phase Output:**
```markdown
# Requirements Document

## Introduction
Implement a secure user authentication system that allows users to register, login, and manage their accounts with proper security measures.

## Requirements

### Requirement 1
**User Story:** As a new user, I want to register for an account, so that I can access the application features.

#### Acceptance Criteria
1. WHEN a user provides valid email and password THEN the system SHALL create a new account
2. WHEN a user provides an already registered email THEN the system SHALL display an error message
3. WHEN a user provides invalid email format THEN the system SHALL display validation error
4. WHEN a user provides weak password THEN the system SHALL display password requirements
```

**Design Phase Output:**
```markdown
# Design Document

## Overview
The authentication system will use JWT tokens with refresh token rotation, bcrypt password hashing, and email verification workflow.

## Architecture
- AuthService: Core authentication logic
- UserRepository: Data persistence layer
- TokenManager: JWT token handling
- EmailService: Verification email sending
```

**Task Phase Output:**
```markdown
# Implementation Plan

- [ ] 1. Set up authentication project structure
  - Create auth service, repository, and model directories
  - Define core interfaces for authentication components
  - _Requirements: 1.1, 2.1_

- [ ] 2. Implement User model with validation
  - Create User class with email and password validation
  - Implement password strength checking
  - Write unit tests for User model
  - _Requirements: 1.1, 1.3, 1.4_
```

This methodology ensures systematic, thorough development of features with clear traceability from user needs to implementation tasks.
## Addi
tional Tools and Templates

### Quick Reference Commands

**Create New Spec Structure:**
```bash
mkdir -p .kiro/specs/[feature-name]
touch .kiro/specs/[feature-name]/requirements.md
touch .kiro/specs/[feature-name]/design.md  
touch .kiro/specs/[feature-name]/tasks.md
```

**Spec File Templates:**

#### requirements.md Template:
```markdown
# Requirements Document

## Introduction

[Brief description of the feature and its value proposition]

## Requirements

### Requirement 1

**User Story:** As a [role], I want [feature], so that [benefit]

#### Acceptance Criteria

1. WHEN [event] THEN [system] SHALL [response]
2. IF [precondition] THEN [system] SHALL [response]

### Requirement 2

**User Story:** As a [role], I want [feature], so that [benefit]

#### Acceptance Criteria

1. WHEN [event] THEN [system] SHALL [response]
2. WHILE [condition] THEN [system] SHALL [response]
```

#### design.md Template:
```markdown
# Design Document

## Overview

[High-level approach and key design decisions]

## Architecture

[System components and relationships]

## Components and Interfaces

[Detailed component breakdown]

## Data Models

[Core data structures and relationships]

## Error Handling

[Error scenarios and recovery strategies]

## Testing Strategy

[Testing approach and coverage]
```

#### tasks.md Template:
```markdown
# Implementation Plan

- [ ] 1. Set up project structure
  - Create directory structure and core interfaces
  - _Requirements: X.X_

- [ ] 2. Implement core models
- [ ] 2.1 Create data models with validation
  - Write model classes with validation logic
  - Create unit tests for models
  - _Requirements: X.X, Y.Y_

- [ ] 2.2 Implement business logic
  - Code core business rules and algorithms
  - Write comprehensive unit tests
  - _Requirements: X.X_

- [ ] 3. Integration and testing
  - Wire components together
  - Create end-to-end tests
  - _Requirements: X.X_
```

### Validation Questions for Each Phase

**Requirements Validation:**
- Does each requirement have a clear user story?
- Are acceptance criteria testable and measurable?
- Have we covered error scenarios and edge cases?
- Are non-functional requirements (performance, security) addressed?
- Can we trace each requirement to user value?

**Design Validation:**
- Does the design address all requirements?
- Are components properly separated and cohesive?
- Is error handling comprehensive?
- Is the design testable and maintainable?
- Have we considered integration points?

**Task Validation:**
- Does each task involve writing/modifying/testing code?
- Are tasks sequenced to build incrementally?
- Do all requirements have corresponding tasks?
- Can each task be completed independently?
- Is test coverage planned throughout?

### Troubleshooting Guide

**If Requirements Feel Incomplete:**
- Review user workflows and identify gaps
- Consider error scenarios and edge cases
- Ask "What could go wrong?" for each user story
- Validate against real user needs

**If Design Feels Complex:**
- Break into smaller, focused components
- Identify core functionality vs nice-to-have features
- Consider phased implementation approach
- Simplify interfaces and reduce coupling

**If Tasks Feel Overwhelming:**
- Break large tasks into smaller sub-tasks
- Ensure each task has clear completion criteria
- Sequence tasks to validate assumptions early
- Focus on minimal viable implementation first

This methodology document should give you everything you need to create comprehensive specs independently. The key is following the systematic approach and using the validation questions to ensure quality at each phase.