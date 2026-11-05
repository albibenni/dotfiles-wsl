# Live FabrickCoreLib source map

Paths below are relative to the library checkout. They are navigation hints, not a frozen dependency allowlist or API specification. Verify existence and content on every invocation; search for moved symbols with `rg`.

| Decision | Read/search |
| --- | --- |
| Parent, supported modules, managed versions, plugins, Java | Root `pom.xml`, `README.md`, relevant module `pom.xml`; follow inherited and transitive declarations |
| Project bootstrap and supported stack | `claude-plugin/skills/fabrick-project-bootstrap/SKILL.md`; verify against `fabrickcore-spring-boot-starter/src/main/java/it/fabrick/core/starter/main/` properties, configuration, listeners and controllers |
| Response envelope | `fabrickcore-model/src/main/java/it/fabrick/core/model/api/v1/ResponseModel.java`, `ResponseStatus.java`, `ErrorModel.java`, `FabrickGenericErrorCode.java`, `utils/ResponseBuilder.java` |
| Lists and pagination | Same v1 directory: `ListResponseModel.java`, `PaginationModel.java`, `SortingModel.java`, pagination/sorting helpers; compare `api/v5/list/response/ListResponse.java` and consumer usages |
| Serialization/error semantics | Model tests, consumer controller/advice tests, module Jackson configuration and exception handlers; search actual usages of the selected model/helper |
| REST clients | `fabrickcore-spring` and `fabrickcore-webflux` client source/tests; `claude-plugin/skills/fabrick-rest-client/SKILL.md`; starter client auto-configuration |
| Persistence | Relevant JDBC/JPA/Hibernate/MyBatis/Mongo module README, POM, implementation and tests; applicable `fabrick-mybatis-*` plugin guidance |
| Cache | `BEST_PRACTICES.md`, `fabrickcore-cache`, Caffeine/Redis starters; `fabrick-cache-client` and `fabrick-redis-setup` plugin guidance |
| Kafka/integration | Selected module README/POM/configuration/tests; applicable `fabrick-kafka-setup` guidance |
| Testing | `fabrickcore-spring-boot-starter-test/pom.xml` and source; `claude-plugin/skills/fabrick-unit-testing/SKILL.md`; `claude-plugin/skills/fabrick-conventions/assets/rules/fabrick-testing.md`; representative module tests |
| Secrets/security/operations | Root `README.md`, `BEST_PRACTICES.md`, `SECURITY_CONTEXT.md`, starter configuration/logging/probes and consumer security context |

## Distinctions to verify

- The inspected response implementation has `status`, `payload`, `errors` and `warnings`; `ErrorModel` has `code`, `description`, `params`. These are model fields, not a guarantee that every field appears in serialized JSON. `ResponseModel.ok(...)` and `ResponseBuilder.buildResponse(...)` can initialize fields differently; verify wire behavior before treating them as interchangeable.
- v1 `ListResponseModel` has one `SortingModel`; v5 `ListResponse` has a list of sorting models. The consumer's API contract determines which belongs in the payload.
- Parent management and starter transitivity are different. Inspect scope/optional/exclusion rules before assuming an artifact is available. In particular, test-scoped dependencies of a production starter do not supply consumer tests.
- Plugin examples can contain literal versions older than the root POM, stale module names, or advice that disagrees with implementation. Verify the matching release rather than copying example versions or migrating a consumer implicitly.
- Local-first caching is a documented preference when appropriate, not a reason to replace shared/distributed semantics required by a use case.
- Reading plugin guidance does not authorize installing rules, changing project settings, bootstrapping unrelated files or running a live service.
