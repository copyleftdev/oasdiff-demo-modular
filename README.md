# OpenAPI Breaking Changes Detection Demo

This repository demonstrates how to implement automated breaking changes detection for OpenAPI specifications using the [oasdiff](https://github.com/oasdiff/oasdiff) tool. Breaking changes detection is a critical practice in API development to ensure backward compatibility and prevent unexpected disruptions for API consumers.

## Project Structure

```
.
├── .github/workflows    # CI/CD configurations
├── api                  # OpenAPI specifications
│   ├── v1               # Base version of the API
│   └── v2               # Updated version of the API to check for breaking changes
└── scripts              # Utility scripts for API validation
```

## How It Works

This project implements two levels of breaking changes detection:

1. **Local Pre-commit Hook**: Prevents committing breaking changes to the repository
2. **GitHub Actions Workflow**: Validates changes in the CI pipeline

Both mechanisms use the `oasdiff` tool to compare OpenAPI specifications and detect potentially breaking changes that could affect API consumers.

## Local Development Setup

### Prerequisites

- Git
- Go 1.21 or later

### Installation

1. Clone this repository
2. Install the oasdiff tool:
   ```bash
   go install github.com/oasdiff/oasdiff@latest
   ```
3. The pre-commit hook is automatically set up when you clone the repository

### Using the Pre-commit Hook

The pre-commit hook automatically runs when you try to commit changes to the repository. It:

1. Identifies modified/added YAML files in the staging area
2. If OpenAPI files are modified, runs the breaking changes check
3. Blocks the commit if breaking changes are detected
4. Allows the commit to proceed if no breaking changes are found

To run the check manually:

```bash
./scripts/check-breaking.sh
```

## GitHub Actions Workflow

The CI/CD pipeline includes a workflow that:

1. Triggers when changes are pushed to files in the `api/` or `scripts/` directories
2. Sets up Go and installs the oasdiff tool
3. Runs the breaking changes check script
4. Fails the build if breaking changes are detected

This ensures that no breaking changes make it into the main branch, even if they bypass the local pre-commit hook.

## Value of Breaking Changes Detection

Implementing automated breaking changes detection provides several benefits:

- **Backward Compatibility**: Ensures changes to the API don't break existing clients
- **Clear Communication**: Helps identify when changes need to be communicated to API consumers
- **Version Management**: Helps enforce proper semantic versioning practices
- **Documentation**: Creates a traceable history of API changes
- **Quality Control**: Prevents accidental regressions in the API

## Types of Breaking Changes Detected

The oasdiff tool can detect a wide range of breaking changes, including:

- Removed endpoints or operations
- Changed parameter requirements
- Modified response structures
- Schema property changes
- Authentication changes
- And many more

## Potential Additional Workflows

This basic setup can be extended in several ways:

### 1. Automatic Changelog Generation

Enhance the workflow to automatically generate a changelog based on detected differences between API versions.

```yaml
- name: Generate Changelog
  run: oasdiff changelog api/v1/openapi.yaml api/v2/openapi.yaml --format markdown > CHANGELOG.md
```

### 2. API Linting and Validation

Add OpenAPI linting to catch specification errors and style issues:

```yaml
- name: Validate OpenAPI
  run: |
    npm install -g @stoplight/spectral-cli
    spectral lint api/v2/openapi.yaml
```

### 3. Documentation Generation

Automatically generate API documentation when the specifications change:

```yaml
- name: Generate Documentation
  run: |
    npm install -g redoc-cli
    redoc-cli bundle api/v2/openapi.yaml -o docs/index.html
```

### 4. Breaking Changes Notification

Send notifications to development teams when potential breaking changes are detected:

```yaml
- name: Notify About Breaking Changes
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    slack-message: "⚠️ Breaking changes detected in the API!"
    slack-channel: "api-development"
```

### 5. API Diff Report Generation

Generate HTML reports visualizing the differences between API versions:

```yaml
- name: Generate Diff Report
  run: oasdiff diff api/v1/openapi.yaml api/v2/openapi.yaml --format html > report.html
```

## Practical Example: Proper API Versioning

This repository includes a practical example of how to properly handle API changes. Here's what we did:

### Before: Breaking Change (Rejected by Pre-commit Hook)

Initially, we attempted to remove the `name` property completely from the Pet schema in v2:

```yaml
# Breaking change that was rejected
Pet:
  type: object
  required:
    - id
  properties:
    id:
      type: integer
    # name property has been removed completely - this breaks compatibility!
```

This change was detected by oasdiff as breaking backward compatibility and was rejected by the pre-commit hook.

### After: Proper Versioning with Deprecation

We then applied proper versioning by:

1. **Keeping but deprecating** the original property:

```yaml
name:
  type: string
  deprecated: true
  description: "This field is deprecated and will be removed in v3.0.0. Use 'displayName' instead."
```

2. **Adding a replacement** field:

```yaml
displayName:
  type: string
  description: "The display name of the pet. Replaces the deprecated 'name' field."
```

3. **Documenting the changes** in the OpenAPI specification:

```yaml
description: |
  # API Changes in 2.0.0
  
  ## Deprecations
  - The `name` property in Pet schema is deprecated and will be removed in v3.0.0
  
  ## New Features
  - Added `displayName` property to Pet schema to replace the deprecated `name` field
  - Added `id` as a required property for Pet objects
```

This approach maintains backward compatibility while clearly communicating the path forward for API consumers.

## Best Practices

1. Always increment the API version appropriately when introducing breaking changes
2. Add deprecation notices before removing endpoints or features
3. Document all changes, whether breaking or non-breaking
4. Use feature flags to gradually roll out changes when possible
5. Follow semantic versioning principles for your API

## Further Reading

- [oasdiff documentation](https://github.com/oasdiff/oasdiff)
- [OpenAPI Specification](https://www.openapis.org/)
- [Semantic Versioning](https://semver.org/)
- [API Change Management Best Practices](https://www.oasdiff.com/)
